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
LAST_DEPLOYED_FILE="/tmp/.cope-last-deploy-commit"
FORCE_FILE="/tmp/.cope-force-deploy"
LOCK_FILE="/tmp/.cope-deploy.lock"
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

# On first start, treat the current commit as already deployed so a daemon
# restart never redeploys running services.
if [ ! -f "$LAST_DEPLOYED_FILE" ]; then
    current_head > "$LAST_DEPLOYED_FILE"
fi

log "Auto-deploy daemon started (interval=${INTERVAL}s)"
log "Repository: $REPO_ROOT"
log "Deploying on new commits to HEAD (force file: $FORCE_FILE)"

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
