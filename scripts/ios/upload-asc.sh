#!/usr/bin/env bash
# App Store Connect: スクショ + メタデータを fastlane deliver でアップロード
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

"$ROOT/scripts/ios/sync-asc-screenshots.sh"

echo "==> fastlane deliver (screenshots + metadata, no IPA)"
fastlane deliver \
  --screenshots_path "$ROOT/fastlane/screenshots" \
  --metadata_path "$ROOT/fastlane/metadata" \
  --skip_binary_upload true \
  --skip_app_version_update false \
  --force true \
  --app_version "1.0" \
  --platform ios

echo "==> Done. Confirm in App Store Connect."
