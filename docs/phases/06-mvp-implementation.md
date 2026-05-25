# MVP実装 — っぽい格言

> Phase 6: MVP実装（一問一答で進行）

## 実装順序（確定）

1. **A** Firebase Firestore（今日の格言取得）
2. **B** 共有画像生成 + 𝕏 ShareLink
3. **C** Cloud Functions + Claude（日次格言生成）
4. **D** AdMob 広告

---

## 実装済み（骨組み）

- [x] オンボーディング（2画面 + 通知許可）
- [x] ホーム画面（格言表示・フェードイン）
- [x] 設定（テーマ3択・字体A/B・通知時刻）
- [x] 考察入力シート + プレビュー UI
- [x] 3テーマカラー
- [x] UserDefaults 永続化

## Phase 6 TODO

- [x] **A** Firebase Firestore 連携（コード + セットアップ手順）
- [x] **B** 共有画像（1200×675）+ ShareSheet（𝕏）
- [x] **C** Cloud Functions（Claude API 日次生成）— `functions/` 作成済み
- [x] **D** AdMob バナー + インタースティシャル ✅

### B 詳細

| 項目 | 値 |
|------|-----|
| 画像サイズ | 1200×675（16:9） |
| 生成 | `ImageRenderer` + `ShareCardExportView` |
| 共有 | `UIActivityViewController`（画像 + テキスト） |

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-19 | P6-D 完了 — AdMob ID 設定 |
| 2026-05-19 | **Phase 6 MVP 実装 完了** |
