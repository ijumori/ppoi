#!/usr/bin/env bash
# TestFlight 向け: Archive → App Store Connect アップロード（CLI）
# 前提: Xcode ログイン済み、Team NXFZ5AUX62、署名 Automatic
#
# 再 Upload 前: ターゲット PPOI の CURRENT_PROJECT_VERSION を +1 すること
# （Info.plist だけでは ASC のビルド番号は変わらない）
# 手順: docs/phases/08-app-store-release.md §8.7
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

TEAM_ID="${DEVELOPMENT_TEAM:-NXFZ5AUX62}"
ARCHIVE_PATH="${ARCHIVE_PATH:-build/PPOI.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-build/export}"

echo "==> Clean build dir"
rm -rf build/export
mkdir -p build

echo "==> Archive (Release, iPhone only)"
xcodebuild \
  -project PPOI.xcodeproj \
  -scheme PPOI \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Automatic \
  archive

echo "==> Export & Upload to App Store Connect"
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist config/ios/ExportOptions.plist \
  -exportPath "$EXPORT_PATH" \
  -allowProvisioningUpdates

echo "==> Done."
echo "    1) ASC TestFlight で 1.0.0 (n) が「終了」になるまで待つ"
echo "    2) 輸出コンプライアンス（いいえ / 免除のみ）→「テスト可能」まで待つ"
echo "    3) 内部テストにビルド追加 → iPhone TestFlight からインストール"
