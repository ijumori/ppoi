# 残作業・引き継ぎ（Mac / Apple Developer 必須）

> 企画・要件の再設計と機能実装（WBS W1〜W8 = v1.1 / v1.2 / v2.0 + v1.3）はコードレベルで完了済み。
> Mac 環境で xcodegen → シミュレータビルド・Firestore 連携確認済み。Cloud Functions デプロイ済み。
> 最終更新: 2026-06-16 / 対象ブランチ: `main`

## ここまでの完了状況

- 再設計ドキュメント一式（`docs/redesign/`）
- v1.1: 創作明示 / お気に入り / ストリーク（`v1.1-design.md`）
- v1.2: 今日の格言ウィジェット（`v1.2-design.md`）
- v2.0: 買い切り課金 StoreKit 2（`v2.0-design.md`）
- v1.3: 一句日記 / カレンダー / 実績8種 / 週間ランキング / freeLimit=10 / AI今日の問い（`docs/v1.2-4.2-rejection-strategy.md` 対応）
- リファクタリング Phase 0・1・2: UserDefaultsStore 分割 / JSTDate 集約 / CI / 43ユニットテスト（`docs/refactoring-plan.md`）
- すべて `main` にマージ・GitHub へ push 済み
- xcodegen generate → シミュレータビルド成功（PPOIWidget 含む）
- Firestore 格言データ投入（11件 seed、2026-06-04〜06-14）
- Cloud Functions デプロイ済み（毎日 0:00 JST 自動生成 + 手動エンドポイント）
- Firebase Blaze プラン移行・シークレット設定済み

## 残作業（優先順）

### 1. ビルド/実機確認 — シミュレータ完了、実機は App Groups 待ち
- ✅ `xcodegen generate` でプロジェクト再生成済み
- ✅ シミュレータビルド・Firestore 連携確認済み（格言表示OK）
- ⬜ iPhone 実機 / Sandbox で動作確認（App Groups 有効化後）
- 確認対象: お気に入り、ストリーク、創作明示、ウィジェット、課金（購入/復元/広告非表示）

### 2. Apple Developer: App Groups 有効化（実機ビルドのブロッカー）
- App ID に **App Groups** ケイパビリティを有効化し `group.com.takahiro.ppoi` を作成
- Xcode 自動署名で App / Widget 両ターゲットに割当
- 未設定だとウィジェットとアプリ間で今日の格言が共有されない

### 3. App Store Connect: IAP 作成（v2.0 課金）
- 非消費型 IAP `com.takahiro.ppoi.premium`（¥400）を作成
- 審査用メタデータ（表示名・説明・スクショ）を登録
- Sandbox で購入・復元を検証

### 4. 運用 — Cloud Functions デプロイ済み
- ✅ Cloud Functions: 毎日 0:00 JST に Claude で格言自動生成 → Firestore 保存
- ✅ Firestore seed データ投入済み（11件、2026-06-04〜06-14）
- ⬜ Firebase Analytics / App Store Connect で計測
- ⬜ Firebase Crashlytics 導入
- ⬜ ASO 戦略（キーワード・スクショ A/B）

## 関連ドキュメント

| 参照 | 内容 |
|------|------|
| [checklist.md](checklist.md) | Phase 01〜08 チェックリスト（次アクション欄） |
| [phase-02-requirements-design.md](phase-02-requirements-design.md) | WBS（W1〜W8 実装状況） |
| [v1.2-design.md](v1.2-design.md) | ウィジェット手動設定の詳細 |
| [v2.0-design.md](v2.0-design.md) | 課金の手動設定の詳細 |
| [../phases/08-app-store-release.md](../phases/08-app-store-release.md) | v1 リリース手順 |
