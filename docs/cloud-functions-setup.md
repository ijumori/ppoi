# Cloud Functions セットアップ — っぽい格言

> P6-C: 毎日 0:00 JST に Claude API で格言を生成

## 構成

```
functions/
├── src/
│   ├── index.ts           # スケジュール + 手動トリガー
│   └── generateQuote.ts   # Claude 呼び出し + Firestore 書き込み
├── package.json
└── tsconfig.json
```

## 1. 前提

- [firebase-setup.md](./firebase-setup.md) の Firebase プロジェクト作成済み
- **Blaze プラン**（従量課金）— Cloud Functions / Secret Manager に必要
- [Anthropic API キー](https://console.anthropic.com/)

## 2. Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

## 3. プロジェクト紐付け

```bash
cp .firebaserc.example .firebaserc
# YOUR_FIREBASE_PROJECT_ID を実際の ID に書き換え
```

## 4. Anthropic API キー（Secret Manager）

```bash
firebase functions:secrets:set ANTHROPIC_API_KEY
# プロンプトで API キーを入力
```

## 5. 依存関係インストール & デプロイ

```bash
cd functions
npm install
cd ..
firebase deploy --only functions,firestore:rules
```

## 6. 動作確認

### 手動トリガー（テスト）

デプロイ後、Firebase Console → Functions → `generateDailyQuoteManual` の URL にアクセス。

または:

```bash
curl https://asia-northeast1-YOUR_PROJECT_ID.cloudfunctions.net/generateDailyQuoteManual
```

成功レスポンス例:

```json
{ "ok": true, "date": "2026-05-19", "text": "...", "tone": "serious" }
```

### スケジュール

| 項目 | 値 |
|------|-----|
| 関数名 | `generateDailyQuoteScheduled` |
| 実行時刻 | 毎日 **0:00 JST**（15:00 UTC） |
| リージョン | `asia-northeast1` |

## 7. Firestore データ

```
quotes/2026-05-19
  text: "..."
  tone: "humorous" | "serious"
  createdAt: Timestamp
```

## 8. コスト目安

| サービス | 目安 |
|----------|------|
| Cloud Functions | 無料枠内（1日1回） |
| Claude API | 1日1リクエスト ≒ 数円未満 |
| Firestore | 無料枠内 |

## 9. トラブルシューティング

| 症状 | 対処 |
|------|------|
| Secret not found | `firebase functions:secrets:set ANTHROPIC_API_KEY` |
| Permission denied (write) | Functions は Admin SDK 使用 — ルール无关 |
| 既存データがある | 同日ドキュメントは再生成しない（スキップ） |
