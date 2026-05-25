#!/usr/bin/env bash
# docs/screenshots → fastlane/screenshots/ja（ASC 登録順）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEST="$ROOT/fastlane/screenshots/ja"
SRC="$ROOT/docs/screenshots"

mkdir -p "$DEST"
cp "$SRC/02-home_clean.png"      "$DEST/01_home.png"
cp "$SRC/01-onboarding1.png"     "$DEST/02_onboarding.png"
cp "$SRC/06-share-preview.png"   "$DEST/03_share_preview.png"
cp "$SRC/08-x-timeline-mock.png" "$DEST/04_x_timeline.png"

echo "Synced 4 screenshots to $DEST"
ls -la "$DEST"
