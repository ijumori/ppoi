# Firebase セットアップ — っぽい格言

> P6-A: Firestore 連携の詳細手順（初回セットアップ用）

所要時間の目安: **30〜45分**

---

## 全体の流れ

```
① Firebase プロジェクト作成
② iOS アプリ登録 + plist ダウンロード
③ Xcode に plist 配置（ターゲットへ追加）
④ Firestore 有効化 + セキュリティルール
⑤ テストデータ投入
⑥ アプリで動作確認
```

---

## 前提

| 項目 | 値 |
|------|-----|
| Apple バンドル ID | `com.takahiro.ppoi` |
| Firestore コレクション | `quotes` |
| ドキュメント ID 形式 | `yyyy-MM-dd`（JST） |
| tone の値 | `humorous` または `serious` |

---

## Step 1: Firebase プロジェクト作成

1. ブラウザで [Firebase Console](https://console.firebase.google.com/) を開く
2. Google アカウントでログイン
3. **プロジェクトを追加**（または **Create a project**）をクリック
4. プロジェクト名: `ppoi`（任意。例: `ppoi-prod`）
5. **続行** → Google Analytics:
   - **今は不要なら無効** で OK（後から有効化可能）
6. **プロジェクトを作成** → 完了まで待つ（数十秒）
7. プロジェクト概要画面が表示されれば OK

---

## Step 2: iOS アプリを Firebase に登録

1. Firebase Console の **プロジェクト概要**（ホーム）を開く
2. アプリ一覧の **iOS+**（Apple アイコン）をクリック  
   ※ 既存アプリがない場合は中央の **iOS** ボタン
3. **Apple バンドル ID** に **必ず** 以下を入力:

```
com.takahiro.ppoi
```

4. アプリのニックネーム: `っぽい格言`（任意）
5. App Store ID: **空欄で OK**
6. **アプリを登録** をクリック
7. **GoogleService-Info.plist をダウンロード** をクリック  
   → `GoogleService-Info.plist` が PC に保存される
8. 以降の画面（SDK 追加手順）は **スキップして OK**（コード側は実装済み）
9. **コンソールに進む** で Step 2 完了

> ⚠️ バンドル ID が Xcode と 1 文字でも違うと Firestore に接続できません。

---

## Step 3: Xcode に plist を配置

### 3-1. ファイルを置く

Finder でダウンロードした `GoogleService-Info.plist` を、以下のフォルダへコピー:

```
PPOI/Resources/GoogleService-Info.plist
```

プロジェクト内のフルパス例:

```
04.Dev/PPOI/PPOI/Resources/GoogleService-Info.plist
```

### 3-2. Xcode プロジェクトへ追加（重要）

**フォルダに置いただけではアプリに同梱されません。** 必ず Xcode から追加してください。

1. Xcode で `PPOI.xcodeproj` を開く
2. 左の Project Navigator で **PPOI → Resources** グループを右クリック
3. **Add Files to "PPOI"...** を選択
4. コピーした `GoogleService-Info.plist` を選択
5. ダイアログで以下を確認:
   - ✅ **Copy items if needed**
   - ✅ **Add to targets: PPOI** にチェック
6. **Add** をクリック

### 3-3. 同梱設定の確認

1. Xcode 左ペインで **PPOI**（青いアイコン）を選択
2. **TARGETS → PPOI → Build Phases** タブ
3. **Copy Bundle Resources** を展開
4. 一覧に **`GoogleService-Info.plist`** があることを確認

```
✅ GoogleService-Info.plist が Copy Bundle Resources にある
❌ ない → Step 3-2 をやり直す
```

### 3-4. plist の中身を確認（任意）

`GoogleService-Info.plist` を Xcode で開き、以下を確認:

| キー | 期待値 |
|------|--------|
| `BUNDLE_ID` | `com.takahiro.ppoi` |
| `PROJECT_ID` | Firebase のプロジェクト ID |
| `GOOGLE_APP_ID` | `1:xxxx:ios:xxxx` 形式 |

### 3-5. セキュリティ

`GoogleService-Info.plist` には API キーが含まれます。**Git にコミットしない**でください。

`.gitignore` に以下があることを確認:

```
GoogleService-Info.plist
```

---

## Step 4: Firestore を有効化

1. Firebase Console 左メニュー → **Build** → **Firestore Database**
2. **データベースの作成** をクリック
3. モード選択:
   - **本番環境モードで開始** を選択（後でルールを設定）
4. ロケーション:
   - **`asia-northeast1`（東京）** を推奨  
   - Cloud Functions も同リージョンのため、レイテンシが低い
5. **有効にする** → 作成完了まで待つ

---

## Step 5: セキュリティルールを設定

1. Firestore Database 画面 → **ルール** タブ
2. 以下に **丸ごと置き換え**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /quotes/{date} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

3. **公開** をクリック

> 書き込みは Cloud Functions（Admin SDK）のみ。クライアントからの write は禁止。

### CLI からデプロイする場合（任意）

プロジェクトルートで:

```bash
firebase login
firebase deploy --only firestore:rules
```

---

## Step 6: テストデータを投入

アプリは **当日の JST 日付** でドキュメントを取得します。

### 今日の日付を確認

例（2026年5月19日）:

```
2026-05-19
```

※ 日付が Firestore のドキュメント ID と **完全一致** しないと「届いていません」扱いになり、プレースホルダーが表示されます。

### Console から手動投入

1. Firestore Database → **データ** タブ
2. **コレクションを開始**（初回）または **コレクション ID を指定して開始**
3. コレクション ID: `quotes`
4. **次へ**
5. 最初のドキュメント:

| 項目 | 値 |
|------|-----|
| ドキュメント ID | `2026-05-19`（**今日の yyyy-MM-dd**） |
| フィールド `text` | `string` → `静寂の中にこそ、真の答えは眠っている` |
| フィールド `tone` | `string` → `serious` |
| フィールド `createdAt` | `timestamp` → 現在時刻 |

6. **保存**

### データ構造（参考）

```
quotes/
  └── 2026-05-19/
        ├── text: "静寂の中にこそ、真の答えは眠っている"
        ├── tone: "serious"
        └── createdAt: 2026-05-19T12:00:00Z
```

### tone の取りうる値

| 値 | 意味 |
|----|------|
| `serious` | シリアスっぽい格言 |
| `humorous` | ユーモア系 |

---

## Step 7: アプリで動作確認

### 7-1. ビルド前チェック

- [ ] `GoogleService-Info.plist` が Copy Bundle Resources にある
- [ ] Firestore に **今日の日付** のドキュメントがある
- [ ] セキュリティルールが `allow read: if true`

### 7-2. 実行

1. Xcode で **Product → Clean Build Folder**（⇧⌘K）
2. 実機またはシミュレータで **Run**（⌘R）
3. オンボーディングを完了してホーム画面へ

### 7-3. 成功の判定

| 状態 | 意味 |
|------|------|
| Firestore の `text` が表示される | ✅ 連携成功 |
| 「静寂の中にこそ…」（プレースホルダー固定文） | ❌ 未連携 or ドキュメントなし |

### 7-4. Xcode コンソールログ

**plist 未配置時**（フォールバックモード）:

```
[PPOI] GoogleService-Info.plist 未配置 — Firestore フォールバックモード
```

**plist 配置後** → このログは **出ない** はず。

---

## Step 8: トラブルシューティング

### プレースホルダーのまま表示される

| 原因 | 確認方法 | 対処 |
|------|----------|------|
| plist 未同梱 | Build Phases → Copy Bundle Resources | Step 3 をやり直す |
| バンドル ID 不一致 | plist の `BUNDLE_ID` | Firebase でアプリ再登録 |
| ドキュメント ID が今日と違う | Firestore のドキュメント ID | 今日の `yyyy-MM-dd` で作成 |
| tone の typo | Firestore の `tone` フィールド | `serious` / `humorous` のみ |
| キャッシュ | UserDefaults に前日分が残っている | アプリ削除 → 再インストール |

### Permission denied

- Firestore **ルール** タブで `allow read: if true` になっているか確認
- **公開** ボタンを押したか確認

### アプリ起動時にクラッシュ

- `GoogleService-Info.plist` の `PROJECT_ID` / `GOOGLE_APP_ID` が空でないか
- plist が `.example` のまま同梱されていないか

### 日付の確認方法

アプリは **JST（Asia/Tokyo）** の `yyyy-MM-dd` を使います。

```swift
// QuoteService が使う日付
DateFormatter.jstDate.string(from: Date())
// 例: "2026-05-19"
```

Firestore のドキュメント ID は **この文字列と完全一致** 必須。

---

## データ取得の流れ（コード）

```
QuoteView（ホーム）
  └─ QuoteViewModel.loadQuote()
       └─ QuoteService.fetchTodayQuote()
            ├─ UserDefaults キャッシュがあれば返す
            └─ FirestoreQuoteRepository.fetchQuote(for: "2026-05-19")
                 ├─ FirebaseBootstrap.isConfigured == false → プレースホルダー
                 ├─ ドキュメントなし → プレースホルダー
                 └─ 取得成功 → Firestore の text を表示
```

---

## 次のステップ

| 段階 | 内容 | ドキュメント |
|------|------|-------------|
| 手動テスト | 上記 Step 7 | 本ドキュメント |
| 自動生成 | 毎日 0:00 JST に Claude で格言生成 | [cloud-functions-setup.md](./cloud-functions-setup.md) |
| 実機テスト | 全画面チェック | [07-testing-checklist.md](./07-testing-checklist.md) |

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-19 | 詳細手順版に拡充（Xcode ターゲット追加・日付一致・トラブルシュート） |
