# 残作業・引き継ぎ（Mac / Apple Developer 必須）

> 企画・要件の再設計と機能実装（WBS W1〜W8 = v1.1 / v1.2 / v2.0）はコードレベルで完了済み。
> **以降はすべて Mac / Apple Developer / App Store Connect が必要**で、Windows 環境では実行できない。ここが本当の停止点。
> 最終更新: 2026-06-01 / 対象ブランチ: `main`

## ここまでの完了状況

- 再設計ドキュメント一式（`docs/redesign/`）
- v1.1: 創作明示 / お気に入り / ストリーク（`v1.1-design.md`）
- v1.2: 今日の格言ウィジェット（`v1.2-design.md`）
- v2.0: 買い切り課金 StoreKit 2（`v2.0-design.md`）
- すべて `main` にマージ・GitHub へ push 済み

## 残作業（優先順）

### 1. ビルド/実機確認（最優先）
- `xcodegen generate` でプロジェクト再生成（新規ファイル・新ターゲット PPOIWidget を取り込み）
- Xcode でビルド → iPhone 実機 / Sandbox で動作確認
- 確認対象: お気に入り、ストリーク、創作明示、ウィジェット、課金（購入/復元/広告非表示）

### 2. Apple Developer: App Groups 有効化（ウィジェット前提）
- App ID に **App Groups** ケイパビリティを有効化し `group.com.takahiro.ppoi` を作成
- Xcode 自動署名で App / Widget 両ターゲットに割当
- 未設定だとウィジェットとアプリ間で今日の格言が共有されない

### 3. App Store Connect: IAP 作成（v2.0 課金）
- 非消費型 IAP `com.takahiro.ppoi.premium`（¥400）を作成
- 審査用メタデータ（表示名・説明・スクショ）を登録
- Sandbox で購入・復元を検証

### 4. 運用（リリース後）
- Firebase Analytics / App Store Connect で計測
- Firebase Crashlytics 導入
- ASO 戦略（キーワード・スクショ A/B）

## 関連ドキュメント

| 参照 | 内容 |
|------|------|
| [checklist.md](checklist.md) | Phase 01〜08 チェックリスト（次アクション欄） |
| [phase-02-requirements-design.md](phase-02-requirements-design.md) | WBS（W1〜W8 実装状況） |
| [v1.2-design.md](v1.2-design.md) | ウィジェット手動設定の詳細 |
| [v2.0-design.md](v2.0-design.md) | 課金の手動設定の詳細 |
| [../phases/08-app-store-release.md](../phases/08-app-store-release.md) | v1 リリース手順 |
