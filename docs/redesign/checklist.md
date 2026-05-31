# 開発リリース チェックリスト（再設計）

> 添付資料「開発リリース チェックリスト」（Phase 01〜08）準拠。
> 状態: ✅ 完了 / 🟡 進行中・部分 / ⬜ 未着手（再設計で新規に検討する項目）。
> v1（出荷版）の実績を踏まえつつ、再設計（次バージョン）視点で更新する。

## Phase 01 — 企画
- ✅ ターゲット・課題・MVPが定義されている（`phase-01-planning.md` §1〜3,5）
- ✅ ペルソナを複数層で言語化（メイン=ハルト + サブ2）（承認済）
- ✅ 競合調査・差別化ポイントが整理されている（§3）
- ✅ 収益モデルが決まっている（買い切りD案 v2.0導入 / v1.1-1.2は広告のみ）（承認済）

## Phase 02 — 設計
- ✅ 機能要件リスト（〜できる形式・優先度付き）（`phase-02-requirements-design.md` §1）
- ✅ 画面一覧が完成している（§2）
- ✅ 画面遷移図が完成している（§3 mermaid）
- ✅ データモデルが設計されている（§4 ER図）
- ✅ API/バックエンド設計が完成している（§5）
- ✅ WBS/差分スケジュールが作成されている（§6）

## Phase 03 — 環境
- ✅ Apple Developer 登録済み
- ✅ Xcode最新版・Bundle ID 設定済み（`com.takahiro.ppoi`）
- ✅ パッケージマネージャ設定済み（SPM: Firebase / GoogleMobileAds）
- ⬜ WidgetKit 用 App Group 設定（W4 着手時）

## Phase 04 — デザイン
- ✅ HIG準拠・ダークモード対応
- ✅ 全画面のモックアップ完成（`docs/design/`）
- 🟡 新規機能のUIモック（お気に入り/ストリーク/ウィジェットは実装で確定、ペイウォールは未）
- ✅ 「創作明示」の文言・配置デザイン（FR-09、v1.1実装）

## Phase 05 — 開発
- ✅ アーキテクチャに従い実装（SwiftUI + MVVM、Features/Core）
- ✅ セキュリティ・メモリ管理を考慮（`docs/guides/security.md`）
- ✅ 再設計 WBS W1〜W4 実装（v1.1 / v1.2）
- ⬜ W5〜W8（買い切り課金、v2.0）
- 🟡 実機ビルド未検証（Mac で `xcodegen generate` → ビルド要）

## Phase 06 — テスト
- 🟡 UnitTest / UITest 実装（拡充余地あり）
- ✅ TestFlightで実機テスト完了（v1）
- ⬜ 新規機能（お気に入り/ストリーク/ウィジェット）の回帰テスト・実機確認

## Phase 07 — 申請
- ✅ スクリーンショット・メタデータ準備完了（`fastlane/` / `docs/guides/app-store-metadata.md`）
- ✅ プライバシー情報・プライバシーポリシーページ用意（`docs/legal/`、GitHub Pages公開）
- 🟡 App Privacy（データ収集申告） — Firebase Console / ASC 設定確認
- ⬜ 課金導入時：App内課金の審査メタデータ（W5着手時）

## Phase 08 — 運用
- ⬜ Analytics 設定（Firebase Analytics / App Store Connect 計測）
- ⬜ Crashlytics 設定
- 🟡 ASO戦略（キーワード・スクショA/B）— 初期メタデータあり、戦略は要策定
- ⬜ アップデートサイクル策定（バグ即時 / 機能2〜4週スプリント）
- ⬜ ユーザー離脱ポイントのファネル分析

## 次アクション（優先順）
1. ✅ Phase 01 の収益モデル・ペルソナ・MVP を承認（2026-05-31）。
2. v1.1 スコープ（W1〜W3）の詳細設計 → [`v1.1-design.md`](v1.1-design.md)。次は実装着手。
3. Phase 08 の Analytics/Crashlytics を運用開始前に導入。

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-31 | チェックリスト作成（Phase01-08、v1実績+再設計視点） |
