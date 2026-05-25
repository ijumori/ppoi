#!/usr/bin/env bash
# App Store 用スクリーンショット・共有画像を生成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
OUTPUT="${SCREENSHOT_OUTPUT_DIR:-$ROOT/docs/screenshots}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 16 Pro Max}"

echo "==> xcodegen"
xcodegen generate

echo "==> Export SwiftUI screenshots (simulator test)"
export SCREENSHOT_OUTPUT_DIR="$OUTPUT"
xcodebuild test \
  -project PPOI.xcodeproj \
  -scheme PPOI \
  -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}" \
  -only-testing:PPOIScreenshotTests/ScreenshotExportTests/testExportShareScreenshots \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tail -20

echo "==> 𝕏 timeline mock (Python)"
if python3 -c "import PIL" 2>/dev/null; then
  python3 "$ROOT/scripts/ios/generate-x-timeline-mock.py"
else
  echo "    Skip: pip install Pillow for 08-x-timeline-mock.png"
fi

echo "==> Done. Files in $OUTPUT"
ls -la "$OUTPUT"/*.png 2>/dev/null | tail -15
