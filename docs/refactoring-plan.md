# リファクタリング計画 — っぽい格言（PPOI）

作成日: 2026-06-11
更新日: 2026-07-20（Phase 0・1・2・3 完了）
対象: `PPOI/`（Swift 約5,600行・約50ファイル）、`PPOIWidget/`、`functions/`、リポジトリ全体

## 0. 現状診断（サマリ)

コードベース全体を監査した結果、**構造自体は健全**（Features / Core / DesignSystem の分離、async/await への統一、セキュリティ設定済みの project.yml）であり、全面書き直しを要する状態ではない。一方で、以下の負債が確認された。

| # | 問題 | 深刻度 | 該当箇所 |
|---|------|--------|----------|
| 1 | ユニットテストが皆無（スクリーンショットテストのみ） | 高 | `PPOIScreenshotTests/` のみ存在 |
| 2 | `UserDefaultsStore` の責務過多（設定+お気に入り+ストリーク+報酬解放+日付計算） | 高 | `PPOI/Core/Persistence/UserDefaultsStore.swift`（243行） |
| 3 | UI パターンの重複（開閉カード、格言フォント選択、背景グラデーション） | 高 | `InterpretationView` / `DailyQuestionView` ほか |
| 4 | 文言のハードコード散在（"AIが紡ぐ創作格言" など5ファイル以上に重複） | 高 | `QuoteView` / `ShareCardExportView` / `ShareImageRenderer` / `QuoteDetailView` / `PPOIWidget` |
| 5 | `try?` による黙殺エラー（キャッシュ・永続化・広告で5箇所以上） | 中 | `SecureQuoteCache` / `UserDefaultsStore` / `InterstitialAdManager` / `AdMobConfig` |
| 6 | シングルトン依存と View 内でのサービス直生成（DI 不在 → テスト不能） | 中 | `StoreManager.shared` / `InterstitialAdManager.shared` / `QuoteViewModel:13` |
| 7 | `VoteView` が独自キーで UserDefaults を直接操作（永続化層の迂回） | 中 | `VoteView.swift:109-121` |
| 8 | マジックナンバー散在（spacing 41箇所、cornerRadius、フォントサイズ、ストリーク閾値 7/30） | 中 | Features 全域 |
| 9 | `OnboardingView` の肥大化（314行、UI+通知許可+状態遷移が混在） | 中 | `OnboardingView.swift` |
| 10 | リポジトリの残骸（`DELETEBOX/`、`project.yml` の `"**/* (1)*"` 除外指定が示す過去のファイル重複） | 低 | `DELETEBOX/docs/screenshots/` |

**方針**: 挙動を変えない段階的リファクタリングを6フェーズで行う。各フェーズは独立して main にマージ・リリース可能な単位とし、ビッグバン書き直しはしない。

---

## 進め方の原則

1. **テストを先に書く**: 振る舞いを固定してから動かす。Phase 1 が他のすべての前提。
2. **1 PR = 1 関心事**: フェーズ内の作業項目ごとに小さく PR を分ける。レビュー可能サイズ（差分 ±400行目安）を守る。
3. **挙動不変**: リファクタリング PR に機能変更・文言変更を混ぜない。混ぜたくなったら別 PR。
4. **各フェーズ完了時に実機確認**: `xcodegen generate && xcodebuild build` + 主要フロー（起動→格言表示→シェア→ウィジェット反映）の手動確認。
5. **永続化キーの互換性維持**: UserDefaults / Keychain / App Group のキー名は変更しない（既存ユーザーのデータ消失防止）。クラスを分割してもキーはそのまま。

---

## Phase 0: 足場づくり・即効クリーンアップ（規模: 小 / 0.5日）

リスクゼロで終わらせられる掃除と、以降のフェーズの安全網を整える。

### 作業項目

- [x] `DELETEBOX/` を削除（中身は旧スクリーンショット4枚のみ。Git 履歴に残るので復元可能）
- [~] `project.yml` の `"**/* (1)/**"` / `"**/* (1)*"` 除外指定を削除（Google Drive 同期による実ファイルが存在することを確認→**意図的に保持**）
- [x] SwiftFormat v0.61.1 を導入し、設定ファイル（`.swiftformat`）をコミット
- [x] CI（GitHub Actions）で `xcodegen generate` + ビルド + SwiftFormat lint を回すワークフローを追加
- [x] `docs/` の索引（`docs/README.md`）に本計画書を追記

### 完了条件

- CI がグリーンで main を保護できる状態
- リポジトリに用途不明のファイルが存在しない

---

## Phase 1: テスト基盤の構築（規模: 中 / 2〜3日）

現状テスト不能な箇所に最小限の縫い目（seam）を入れ、コアロジックをユニットテストで固定する。**ここでのリファクタリングは「テストを書くために必要な最小限」に留める。**

### 作業項目

- [x] `PPOITests`（unit-test target）を `project.yml` に追加
- [x] `UserDefaultsStore` のテスト（10テスト）: ストリーク連続判定・JST 跨ぎ・同日冪等性・報酬解放 7d/30d・お気に入り上限100件
- [x] `QuoteService` のテスト（5テスト）: キャッシュヒット / フォールバック3系統（firebaseNotConfigured / documentNotFound / untrustedEnvironment）/ 成功パス。Keychain 汚染防止の `tearDown` 追加
- [x] `QuoteViewModel` に `QuoteService` をイニシャライザ注入できるよう変更（3テスト）。同 Keychain tearDown 追加
- [x] `ShareCardExportView.quoteFontSize` を純粋 static 関数として切り出し（14テスト）
- [x] `functions/` に vitest v2.1.9 を導入し、`generateQuote.ts` のレスポンス抽出・カテゴリ検証・エラーケースを 11 テストで固定

### 完了条件

- ストリーク・報酬・キャッシュフォールバックの3領域がテストで固定されている
- CI でユニットテストが実行される

### リスク

- なし（プロダクションコードの変更は `QuoteViewModel` の DI 化のみ）

---

## Phase 2: 永続化レイヤの分割（規模: 中 / 2〜3日）

`UserDefaultsStore` を単一責務のクラスに分割し、迂回している永続化アクセスを統合する。**Phase 1 のテストが回帰を検知できる状態で着手すること。**

### 作業項目

- [x] `UserDefaultsStore` を以下に分割（キー名は既存のまま維持）:
  - `UserPreferencesStore` — onboarding 完了、テーマ、通知、フォント
  - `FavoritesStore` — お気に入り CRUD と上限管理
  - `StreakTracker` — 訪問記録、連続日数、`visitedDates`、日付計算
  - `RewardUnlocker` — ストリーク報酬の判定・解放（`StreakTracker` に依存）
- [x] 日付ユーティリティ（JST 固定の `DateFormatter.jstDate`、連続日判定）を `Core/Utilities/JSTDate.swift` に集約
- [x] `VoteView.swift:109-121` のローカル投票永続化（`votedDate` / `votedReaction` キー直接アクセス）を `StreakTracker.recordVote()` に移管
- [x] `AppState` / 各 View の参照を新クラスに差し替え。`@Observable` の粒度が細かくなることで不要な再描画も減る
- [x] 分割後、`SecureQuoteCache` への委譲（`cacheQuote` / `cachedQuote`）は `QuoteService` 直下に移し、Store 経由の間接参照を解消

### 完了条件

- `UserDefaultsStore` が消滅し、各クラスが100行未満・単一責務
- 既存端末でアップグレードしてもストリーク・お気に入り・設定が保持される（キー互換の手動確認）
- Phase 1 のテストがすべてグリーン

### リスク

- **中**: 永続化データの互換性。キー名を変えないことを PR レビューの必須確認項目にする

---

## Phase 3: UI 重複の解消と DesignSystem 拡充（規模: 中 / 2〜3日）

散在するマジックナンバー・重複コンポーネント・重複文言を DesignSystem に集約する。

### 作業項目

- [x] `DesignSystem/Spacing.swift` / `Radius.swift` を新設。実在値（spacing 2/4/6/8/12/16/24/32/48、radius 6/8/10/12/16）に 1:1 で対応させ、置換してもピクセルが変わらないスケールにした。**全 41 箇所の一括機械置換はしない**（`.padding(2/6/10)` など非モジュラーな値が混在し、無理に丸めると挙動が変わるため）。各ファイルを別作業で触るタイミングで随時採用する方針に変更
- [x] `InterpretationView` と `DailyQuestionView` の開閉 UI を `ExpandableCard`（`DesignSystem/ExpandableCard.swift`）に統合。副次的に VStack spacing を 12 に統一し、Interpretation の開示アニメを共通 transition に正規化（微小な視覚差分あり）
- [x] 格言フォント選択を `FontVariant.fontDesign` / `quoteFont(size:)`（`DesignSystem/QuoteFont.swift`）に集約。`QuoteView` / `QuoteDetailView` / `ShareCardExportView` の 3 箇所を置換
- [x] テーマ背景グラデーションを `ThemedBackground`（`DesignSystem/ThemedBackground.swift`）に集約。対象は `QuoteView` / `QuoteDetailView`。`OnboardingView` は単色背景のみで挙動が異なるため対象外
- [x] `AppStrings`（`DesignSystem/AppStrings.swift`）を新設し、"AIが紡ぐ創作格言"・"明日には消える一句"・"#っぽい格言" の重複を解消。**将来ローカライズするなら String Catalog（`.xcstrings`）へ移す**（現時点では日本語のみ）
- [x] ストリーク閾値（7 / 30）を `StreakReward.streakThemeDays` / `masterTitleDays` に集約。`RewardUnlocker` の比較と `SettingsView` の解放ラベルを定数から導出

### 完了条件

- [x] 同一文言・同一スタイルの定義箇所が1つになっている（対象範囲）
- [x] 新規画面が DesignSystem の定数（Spacing / Radius / AppStrings / ThemedBackground / ExpandableCard）でレイアウトを組める状態

### リスク

- **低**: 見た目のピクセル差分。各増分で `xcodebuild build` 成功 + `PPOITests` 33/33 pass を確認済み。スクリーンショットテストによる目視差分確認は残（手動）

### 実績（コミット）

- `ExpandableCard` + Spacing/Radius 新設
- `AppStrings` で文言一元化
- `ThemedBackground` 抽出
- `FontVariant` フォントヘルパー集約
- `StreakReward` 閾値の単一ソース化

---

## Phase 4: アーキテクチャ整理 — DI・エラー処理・肥大 View 分割（規模: 中〜大 / 3〜4日）

### 作業項目

- [ ] **DI の整備**: `AppState`（または軽量な `AppDependencies`）をコンポジションルートとし、`StoreManager.shared` / `InterstitialAdManager.shared` への直接参照を environment 経由の注入に置換。シングルトン自体は残してよいが、参照点を App 層に限定する
- [ ] **エラー処理ポリシーの統一**: 「ユーザー影響のない失敗も必ず `SecureLogger` に記録する」を規約化し、黙殺している `try?` / 空 catch を修正
  - `QuoteViewModel.loadQuote` の catch（現状ログなしでフォールバック）
  - `SecureQuoteCache` の encode/decode 失敗
  - `UserDefaultsStore`（分割後の各 Store）の encode 失敗
  - `AdMobConfig` の plist 読み込み失敗
- [ ] `QuoteViewModel.syncWidget()` の暗黙呼び出しを見直し: ウィジェット同期を `WidgetSyncService` として切り出し、`loadQuote` 成功時に明示的に呼ぶ構造へ
- [ ] `OnboardingView`（314行）の分割: 各ページを独立 View に、通知許可リクエスト＋完了処理を `OnboardingCoordinator`（または AppState のメソッド）に移動
- [ ] `InterstitialAdManager` の `showAfterShare()` のネストした Task + sleep + キャンセルロジックを整理し、状態遷移をテスト可能な形に
- [ ] `MyPageView` の `URL(string:)!` 強制アンラップを定数化（`AppLinks` enum）

### 完了条件

- View / ViewModel が依存をすべて注入で受け取り、`*.shared` の参照が App 層以外に存在しない
- 黙殺エラーがゼロ（grep で `try?` を監査し、意図的なものはコメントで理由を明記）

### リスク

- **中**: 広告表示タイミングのデグレード。実機で「シェア後インタースティシャル」の動作確認を必須とする

---

## Phase 5: 周辺コードとリポジトリ衛生（規模: 小 / 1〜2日)

### 作業項目

- [ ] `functions/src/generateQuote.ts`: `existing.data()!` のガード追加、`as QuoteTone` をバリデーション関数に置換、Claude レスポンス抽出失敗時のエラーハンドリング明示化
- [ ] `PPOIWidget` と本体の重複（日付処理・格言整形）を `SharedQuoteStore` 側に寄せ、ウィジェットを薄くする
- [ ] `docs/` の棚卸し: `docs/phases/`（v1 出荷時の記録）と `docs/redesign/` の現状乖離を確認し、古い記述に「アーカイブ」注記を付与。`README.md` / `AGENTS.md` の「現在フェーズ」を実態に同期
- [ ] `.firebaserc` のコミット是非を判断（プロジェクト ID は公開情報のため許容可だが、`.example` と二重管理になっている）
- [ ] `scripts/ios/` のシェルスクリプトに `set -euo pipefail` 等の基本ガードがあるか監査

### 完了条件

- ドキュメントが現状を正しく説明している
- functions のテストがグリーン

---

## 全体スケジュールと依存関係

```
Phase 0 (0.5日) ──→ Phase 1 (2-3日) ──→ Phase 2 (2-3日) ──→ Phase 4 (3-4日)
                          │
                          └──────────→ Phase 3 (2-3日) ────────┘
                                                Phase 5 (1-2日) は随時並行可
```

- 合計目安: **11〜16人日**(レビュー・実機確認込み)
- Phase 3 は Phase 2 と独立して進められる(UI 層と永続化層で衝突しない)
- Phase 4 は Phase 1・2 完了が前提(テストと分割済み Store がないと DI 整理が空転する)

## やらないこと（スコープ外）

- アーキテクチャパターンの全面変更（TCA 導入等）— 現規模では過剰
- 多言語ローカライズの実施 — String Catalog 化までで止める
- Firestore スキーマ変更・サーバーサイド再設計
- 機能追加・UI デザイン変更（v2.0 課金などは別トラック）

## 各フェーズ共通の完了チェックリスト

- [ ] `xcodegen generate` → `xcodebuild -scheme PPOI build` 成功
- [ ] ユニットテスト・スクリーンショットテストがグリーン
- [ ] 既存ユーザーデータ（UserDefaults / Keychain / App Group）の互換性確認
- [ ] 主要フロー手動確認: 起動 → 今日の格言 → シェア → ウィジェット反映 → 投票 → マイページ
- [ ] 差分に機能変更が混入していないことのレビュー確認
