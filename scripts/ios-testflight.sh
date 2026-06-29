#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/apps/ios"
CONFIG_PATH="$IOS_DIR/Config/release.json"
PROJECT_SPEC="$IOS_DIR/project.yml"
EXPORT_OPTIONS="$IOS_DIR/ExportOptions.plist"
ARCHIVE_PATH="${COPE_IOS_ARCHIVE_PATH:-$IOS_DIR/build/COPE.xcarchive}"
EXPORT_PATH="${COPE_IOS_EXPORT_PATH:-$IOS_DIR/build/export}"
SCHEME="${COPE_IOS_SCHEME:-COPE Production}"
CONFIGURATION="${COPE_IOS_CONFIGURATION:-Release}"

usage() {
  cat <<'EOF'
Usage: scripts/ios-testflight.sh <command>

Commands:
  validate  Check release config, XcodeGen spec, and export options.
  archive   Generate the Xcode project and create a production archive.
  export    Export an IPA from the production archive.
  upload    Upload the exported IPA to App Store Connect.
  all       Run archive, export, then upload.

Upload environment:
  APP_STORE_CONNECT_API_KEY_ID       App Store Connect API key ID.
  APP_STORE_CONNECT_API_ISSUER_ID    App Store Connect issuer ID.
  APP_STORE_CONNECT_API_KEY_PATH     Optional path to AuthKey_<key ID>.p8.

Optional:
  COPE_IOS_ALLOW_PROVISIONING_UPDATES=1  Pass -allowProvisioningUpdates to xcodebuild.
  COPE_IOS_ARCHIVE_PATH                  Override archive output path.
  COPE_IOS_EXPORT_PATH                   Override IPA export directory.
  COPE_IOS_SCHEME                        Override Xcode scheme.
  COPE_IOS_CONFIGURATION                 Override Xcode build configuration.
EOF
}

read_release_field() {
  local field="$1"
  node -e "const config = require(process.argv[1]); const value = config[process.argv[2]]; if (!value) process.exit(1); process.stdout.write(String(value));" "$CONFIG_PATH" "$field"
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
}

provisioning_args() {
  if [[ "${COPE_IOS_ALLOW_PROVISIONING_UPDATES:-0}" == "1" ]]; then
    printf '%s\n' "-allowProvisioningUpdates"
  fi
}

validate_release_config() {
  require_command node

  local team_id app_id bundle_id
  team_id="$(read_release_field appleTeamId)"
  app_id="$(read_release_field appStoreConnectAppId)"
  bundle_id="$(read_release_field productionBundleIdentifier)"

  if [[ "$team_id" != "TKXPY255A2" ]]; then
    echo "Unexpected Apple Team ID in $CONFIG_PATH: $team_id" >&2
    exit 1
  fi

  if [[ "$app_id" != "6785638840" ]]; then
    echo "Unexpected App Store Connect App ID in $CONFIG_PATH: $app_id" >&2
    exit 1
  fi

  if [[ "$bundle_id" != "com.cope.app" ]]; then
    echo "Unexpected production bundle identifier in $CONFIG_PATH: $bundle_id" >&2
    exit 1
  fi

  grep -q "DEVELOPMENT_TEAM: $team_id" "$PROJECT_SPEC" || {
    echo "XcodeGen spec does not use Apple Team ID $team_id" >&2
    exit 1
  }

  grep -q "PRODUCT_BUNDLE_IDENTIFIER: $bundle_id" "$PROJECT_SPEC" || {
    echo "XcodeGen spec does not use production bundle identifier $bundle_id" >&2
    exit 1
  }

  grep -q "<string>$team_id</string>" "$EXPORT_OPTIONS" || {
    echo "ExportOptions.plist does not use Apple Team ID $team_id" >&2
    exit 1
  }

  grep -q "<string>app-store-connect</string>" "$EXPORT_OPTIONS" || {
    echo "ExportOptions.plist is not configured for App Store Connect export" >&2
    exit 1
  }

  echo "iOS release config valid: team=$team_id appStoreId=$app_id bundle=$bundle_id"
}

generate_project() {
  require_command npm
  npm run native:ios:generate
}

archive_app() {
  require_command xcodebuild
  validate_release_config
  generate_project

  mkdir -p "$(dirname "$ARCHIVE_PATH")"

  local -a extra_args=()
  while IFS= read -r arg; do
    [[ -n "$arg" ]] && extra_args+=("$arg")
  done < <(provisioning_args)

  xcodebuild \
    -project "$IOS_DIR/COPE.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    "${extra_args[@]}" \
    archive
}

export_app() {
  require_command xcodebuild
  validate_release_config

  if [[ ! -d "$ARCHIVE_PATH" ]]; then
    echo "Archive not found at $ARCHIVE_PATH. Run archive first." >&2
    exit 1
  fi

  rm -rf "$EXPORT_PATH"
  mkdir -p "$EXPORT_PATH"

  local -a extra_args=()
  while IFS= read -r arg; do
    [[ -n "$arg" ]] && extra_args+=("$arg")
  done < <(provisioning_args)

  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    "${extra_args[@]}"
}

find_exported_ipa() {
  find "$EXPORT_PATH" -maxdepth 1 -name "*.ipa" -type f -print -quit
}

install_api_key_if_needed() {
  local key_id="$1"
  local source_path="${APP_STORE_CONNECT_API_KEY_PATH:-}"

  if [[ -z "$source_path" ]]; then
    return
  fi

  if [[ ! -f "$source_path" ]]; then
    echo "APP_STORE_CONNECT_API_KEY_PATH does not point to a file: $source_path" >&2
    exit 1
  fi

  local key_dir="$HOME/.appstoreconnect/private_keys"
  local key_dest="$key_dir/AuthKey_${key_id}.p8"
  mkdir -p "$key_dir"
  cp "$source_path" "$key_dest"
  chmod 600 "$key_dest"
}

upload_app() {
  require_command xcrun
  validate_release_config

  local key_id="${APP_STORE_CONNECT_API_KEY_ID:-}"
  local issuer_id="${APP_STORE_CONNECT_API_ISSUER_ID:-}"

  if [[ -z "$key_id" || -z "$issuer_id" ]]; then
    echo "APP_STORE_CONNECT_API_KEY_ID and APP_STORE_CONNECT_API_ISSUER_ID are required for upload." >&2
    exit 1
  fi

  local ipa_path
  ipa_path="$(find_exported_ipa)"
  if [[ -z "$ipa_path" ]]; then
    echo "No exported IPA found in $EXPORT_PATH. Run export first." >&2
    exit 1
  fi

  install_api_key_if_needed "$key_id"

  xcrun altool \
    --upload-app \
    --type ios \
    --file "$ipa_path" \
    --apiKey "$key_id" \
    --apiIssuer "$issuer_id"
}

main() {
  local command="${1:-}"
  case "$command" in
    validate)
      validate_release_config
      ;;
    archive)
      archive_app
      ;;
    export)
      export_app
      ;;
    upload)
      upload_app
      ;;
    all)
      archive_app
      export_app
      upload_app
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      echo "Unknown command: $command" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
