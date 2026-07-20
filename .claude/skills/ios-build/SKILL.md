---
name: ios-build
description: PPOI(っぽい格言)の Xcode プロジェクトを再生成してビルドする。「ビルドして」「project.yml を反映」「xcodegen」「ビルド通るか確認」と言われたら使う。
---

# ios-build — PPOI ビルド

PPOI は XcodeGen 生成物。`.xcodeproj` は直接編集せず、`project.yml` を編集 → 再生成 → ビルドする。

## 手順

1. `project.yml` を変更した場合はプロジェクトを再生成する。
   ```bash
   xcodegen generate
   ```
2. シミュレータ向けにビルドする。
   ```bash
   xcodebuild -scheme PPOI \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
   ```
   - シミュレータ名は環境に合わせて調整（`xcrun simctl list devices available` で確認）。
   - リリース確認は `-configuration Release` を付ける。

## 注意

- `* (1)` は Google Drive の同期重複。編集しない（`project.yml` の excludes で除外済み）。
- 依存は SPM（Firebase, GoogleMobileAds）。初回や解決失敗時は `-resolvePackageDependencies` を先に実行。
- `GoogleService-Info.plist` / `AdMobConfig.plist` は gitignore。無い環境では optional 扱いだが Firebase 初期化は失敗しうる。
- ビルドエラーは該当 Swift ファイルを読んで修正 → 再ビルドで確認。CLAUDE.md のコード規約（SwiftFormat）に合わせる。
