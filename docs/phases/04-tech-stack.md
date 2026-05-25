# 技術選定 — っぽい格言

> Phase 4: 技術選定（一問一答で記入）

## §1 バックエンド

**P4-Q1**: 格言配信バックエンド

**回答**: **A. Firebase**

| コンポーネント | 用途 |
|----------------|------|
| Firestore | 日付ごとの格言データ保存 |
| Cloud Functions | 毎日0時 JST に AI 生成 + Firestore 書き込み |

- iOS: Firebase iOS SDK
- 無料枠（Spark → 必要に応じて Blaze）で開始

**確定**: ✅

---

## §2 AI API

**P4-Q2**: 格言生成 AI API

**回答**: **C. Anthropic Claude**

- Cloud Functions から Claude API を呼び出し
- モデル: `claude-sonnet-4-20250514`（暫定 — コスト・品質バランス）
- API キー: Firebase Functions の環境変数 / Secret Manager で管理
- 詩的・文学的な文体に強み → アプリのトーンに合致

**確定**: ✅

---

## §3 データ保存（ローカル）

**P4-Q3**: アプリ内ローカル保存

**回答**: **A. UserDefaults のみ**

| キー | 内容 |
|------|------|
| `hasCompletedOnboarding` | オンボード完了 |
| `selectedTheme` | テーマ A/B/C |
| `notificationEnabled` | 通知 ON/OFF |
| `notificationHour` | 通知時刻（デフォルト 12） |
| `fontVariant` | 字体 A/B |
| `cachedQuoteDate` | キャッシュした格言の日付 |
| `cachedQuoteText` | キャッシュした格言本文 |

- お気に入り（Should）は MVP では未実装
- オフライン: 当日分を UserDefaults にキャッシュ

**確定**: ✅

---

## §4 共有画像

**P6-B-Q1**: 画像サイズ → **A. 1200×675（16:9）**

**確定**: ✅

---

## §5 プッシュ通知

**回答**: **A. ローカル通知**

- `UNUserNotificationCenter` で毎日指定時刻に通知
- ユーザー設定時刻（デフォルト 12:00）に `UNCalendarNotificationTrigger` をスケジュール
- FCM は MVP では不使用（サーバー不要）

**確定**: ✅

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-19 | P4-Q3 確定 — UserDefaults |
| 2026-05-19 | P5-Q1 確定 — ローカル通知 |
