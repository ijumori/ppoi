# CLAUDE.md — PPOI（っぽい格言）

日付同期の「っぽい格言」iOS アプリ。SwiftUI + Firebase + AdMob + StoreKit 2。

## 重要な前提（このリポジトリ特有）

- **配置場所は Google Drive 同期領域**（`~/マイドライブ（…）/04.Dev/PPOI`）。ユーザー共通ルールでは Drive 内で git 操作は原則禁止だが、本プロジェクトは業務マップ上ここが正となっている。git 操作をする場合は必ず事前確認する。
- **`* (1)` は Google Drive の同期重複ファイル**（例: `SharedQuoteStore (1).swift`, `PPOIWidget (1)/`, `PPOI (1).storekit`）。**編集・参照しない。** `.gitignore` と `project.yml` の `excludes`（`**/* (1)/**`, `**/* (1)*`）で除外済み。正本は `(1)` の付かない方。
- Bundle ID: `com.takahiro.ppoi` / Team: `NXFZ5AUX62` / App ID(ASC): `6771264998`

## ビルド / 実行

Xcode プロジェクトは **XcodeGen 生成物**。`.xcodeproj` は直接編集せず、`project.yml` を編集して再生成する。

```bash
xcodegen generate                                                    # project.yml → PPOI.xcodeproj
xcodebuild -scheme PPOI \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build     # ビルド
```

- Deployment Target: iOS 17.0 / Swift 5.0 / Xcode 16
- 対応デバイス: iPhone + iPad（`TARGETED_DEVICE_FAMILY: 1,2`）
- SPM 依存: Firebase iOS SDK（Firestore, AppCheck）, GoogleMobileAds
- ターゲット: `PPOI`（アプリ）/ `PPOIWidget`（ウィジェット拡張）/ `PPOITests` / `PPOIScreenshotTests`
- 実行時は `PPOI.storekit` を StoreKit コンフィグとして使用

## テスト

```bash
xcodebuild -scheme PPOI \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

- ユニットテスト: `PPOITests/`（QuoteService, QuoteViewModel, ShareCardFontSize, UserDefaultsStore）
- スクショテスト: `PPOIScreenshotTests/`（App Store 素材書き出し）
- Cloud Functions: `cd functions && npm test`（vitest）

## リリース（TestFlight / App Store）

再アップロード前に **`project.yml` の `CURRENT_PROJECT_VERSION` を +1**（Info.plist だけではビルド番号が変わらない）→ `xcodegen generate`。

```bash
./scripts/ios/testflight-upload.sh   # Archive(Release) → export → ASC アップロード
./scripts/ios/upload-asc.sh          # スクショ＋メタデータを deliver で登録
```

- 審査提出は fastlane（`fastlane/Fastfile`）または ASC 手動。**publish/提出は必ず事前確認**。
- 手順詳細: `docs/phases/08-app-store-release.md`
- リジェクト対応は Skill `asc-reject` を使う。

## 構成

```
PPOI/
├── App/            エントリ（PPOIApp / RootView / MainTabView）
├── Features/       画面（Quote, Share, Explore, Favorites, MyPage, Vote, Archive, Ads, Purchase, Onboarding, Settings, Review, Invite）
├── Core/
│   ├── Data/           Models / QuoteService / Repositories(Firestore, Ranking)
│   ├── Persistence/    UserPreferences / Favorites / Journal / Streak / Achievement / RewardUnlocker / SharedQuoteStore
│   ├── Infrastructure/ Firebase / AdMob / Notifications
│   ├── Security/       AppCheck・Keychain・入力サニタイズ・ランタイム保護（多層防御）
│   └── Utilities/      JSTDate（日付は JST 基準）
├── DesignSystem/   AppTheme
└── Resources/      Info.plist / entitlements / GoogleService-Info.plist(gitignore)

functions/          Cloud Functions（日次格言生成, Anthropic SDK, TypeScript）
docs/               phases(00-08) / redesign / guides / legal(GitHub Pages) / screenshots
config/ios,firebase ExportOptions.plist / firestore.rules
scripts/ios/        TestFlight・ASC・スクショ
fastlane/           メタデータ・審査提出
```

## コード規約

- SwiftFormat 準拠（`.swiftformat`）: 4スペースインデント, `redundantSelf`/`redundantReturn`, 引数は before-first で改行。`sortImports`/`organizeDeclarations` は無効。
- 日付ロジックは `JSTDate`（JST）を基準にする。
- Secrets（`GoogleService-Info.plist`, `AdMobConfig.plist`, `*.p8` 等）はコミットしない（`.gitignore` 済み）。チャットにも貼らない。
- セキュリティ設計は `docs/guides/security.md` を参照。ビルド設定に多層防御（ASLR, stack protector, symbol strip 等）が入っている。

## 現在フェーズ

**v1.3.0 (Build 11) — App Store 提出前 / リファクタリング進行中**

- v1.2: 3タブ・iPad対応・AI解読・Explore・MyPage
- v1.3: 一句日記 / カレンダー / 実績8種 / 週間ランキング / お気に入り上限（無料10・プレミアム1000）
- v2.0: 買い切り課金（StoreKit 2）
- リファクタリング: Phase 0〜2 完了 / 3〜5 進行中（`docs/refactoring-plan.md`）
- 次アクション: v1.3 を ASC 提出

## 役割（Cursor ルール / AGENTS.md）

PO（要件）→ UI/UX（設計）→ iOS Dev（実装）→ QA（テスト）→ Release（公開）。`.cursor/rules/agent-*.mdc` に各役割の指針。

## AIカンパニーのエージェントロースター
このマシンには`~/.claude/agents/`にClaude Code用の専門エージェントが271体グローバル配置されている（[ijumori/ai-company](https://github.com/ijumori/ai-company)の`agents-roster/`で管理・全社共通）。Agentツールで名前を指定すればこのプロジェクトからも呼び出せる。
おすすめ：`Mobile App Builder`／`Mobile Release Engineer`（App Store提出）／`App Store Optimizer`。
全271体・18部門の一覧：[DIVISIONS.md](https://github.com/ijumori/ai-company/blob/main/agents-roster/DIVISIONS.md)
