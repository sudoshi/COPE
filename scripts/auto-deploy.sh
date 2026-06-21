#!/usr/bin/env bash
# COPE Auto-Deploy Daemon
# Deploys when a new commit lands on the checked-out branch (local HEAD moves).
# Uncommitted working-tree edits do NOT trigger deploys — production only runs
# committed code. For an emergency working-tree deploy without a commit:
#   touch /tmp/.cope-force-deploy
#
# Usage: runs as systemd service (cope-auto-deploy.service)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Persistent across reboots (NOT /tmp) so a commit that landed while the daemon
# was down is still detected on boot. /tmp would be cleared, making the daemon
# assume HEAD is already deployed and silently serve a stale dist.
LAST_DEPLOYED_FILE="/var/lib/cope/last-deploy-commit"
FORCE_FILE="/tmp/.cope-force-deploy"
LOCK_FILE="/tmp/.cope-deploy.lock"
DIST_DIR="$REPO_ROOT/apps/web/dist"
INTERVAL=60

cd "$REPO_ROOT"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

current_head() {
    # Daemon runs as root; the repo belongs to smudoshi (git refuses
    # cross-owner repos as "dubious ownership").
    sudo -u smudoshi git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "unknown"
}

deploy() {
    local head="$1"

    # Prevent concurrent deploys
    if [ -f "$LOCK_FILE" ]; then
        log "Deploy already in progress, skipping."
        return
    fi
    touch "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' RETURN

    log "Rebuilding at commit ${head:0:7}..."
    if sudo -u smudoshi npm run build --silent 2>&1; then
        log "Build succeeded. Restarting services..."
        # Ensure Apache (www-data) can read the freshly built static files.
        # The cope vhost serves apps/web/dist with FallbackResource /index.html,
        # so a build that writes index.html without the world-read bit 403s the
        # ENTIRE SPA (caused an 8-day outage Jun 13-21 2026). Self-heal perms.
        chmod -R a+rX "$REPO_ROOT/apps/web/dist"
        /usr/bin/systemctl restart cope-api cope-worker
        sleep 2

        API_STATUS=$(systemctl is-active cope-api 2>/dev/null || true)
        WORKER_STATUS=$(systemctl is-active cope-worker 2>/dev/null || true)

        if [ "$API_STATUS" = "active" ] && [ "$WORKER_STATUS" = "active" ]; then
            echo "$head" > "$LAST_DEPLOYED_FILE"
            log "Deploy complete. API=$API_STATUS Worker=$WORKER_STATUS"
        else
            log "WARNING: Services not healthy. API=$API_STATUS Worker=$WORKER_STATUS"
        fi
    else
        log "Build FAILED — services not restarted."
    fi
}

mkdir -p "$(dirname "$LAST_DEPLOYED_FILE")"

log "Auto-deploy daemon started (interval=${INTERVAL}s)"
log "Repository: $REPO_ROOT"
log "Deploying on new commits to HEAD (force file: $FORCE_FILE)"

# ---------------------------------------------------------------------------
# Boot-time reconciliation — what makes COPE reliable across reboots.
# Unconditionally re-assert static-file perms (a manual/cache-restored build can
# leave index.html unreadable -> Apache 403s the whole SPA), then rebuild if the
# on-disk dist is missing or no longer matches HEAD (e.g. a commit landed while
# the daemon was down). A normal daemon restart where dist already matches HEAD
# is a no-op, so running services are left undisturbed.
# ---------------------------------------------------------------------------
[ -d "$DIST_DIR" ] && chmod -R a+rX "$DIST_DIR" 2>/dev/null || true

STARTUP_HEAD="$(current_head)"
LAST="$(cat "$LAST_DEPLOYED_FILE" 2>/dev/null || echo "")"
LAST_SHORT="${LAST:0:7}"; [ -z "$LAST_SHORT" ] && LAST_SHORT="none"
if [ "$STARTUP_HEAD" = "unknown" ]; then
    log "Startup: cannot resolve HEAD — skipping reconciliation."
elif [ ! -r "$DIST_DIR/index.html" ]; then
    log "Startup: dist/index.html missing or unreadable — building ${STARTUP_HEAD:0:7}."
    deploy "$STARTUP_HEAD"
elif [ "$STARTUP_HEAD" != "$LAST" ]; then
    log "Startup: on-disk build ($LAST_SHORT) != HEAD (${STARTUP_HEAD:0:7}) — redeploying."
    deploy "$STARTUP_HEAD"
else
    log "Startup: dist matches HEAD ${STARTUP_HEAD:0:7} — no rebuild needed."
fi

while true; do
    HEAD_NOW=$(current_head)
    LAST=$(cat "$LAST_DEPLOYED_FILE" 2>/dev/null || echo "")

    if [ -f "$FORCE_FILE" ]; then
        rm -f "$FORCE_FILE"
        log "Force-deploy requested — building working tree as-is."
        deploy "$HEAD_NOW"
    elif [ "$HEAD_NOW" != "unknown" ] && [ "$HEAD_NOW" != "$LAST" ]; then
        log "New commit detected: ${LAST:0:7} → ${HEAD_NOW:0:7}"
        deploy "$HEAD_NOW"
    fi

    sleep "$INTERVAL"
done
