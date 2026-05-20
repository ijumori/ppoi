# Phase 8: App Store リリース準備 — っぽい格言

> 更新: 2026-05-20  
> Bundle ID: `com.takahiro.ppoi`  
> App Store Connect: 登録済み ✅

---

## 進捗チェックリスト

| # | 項目 | 状態 | 担当 |
|---|------|------|------|
| 8.0 | GitHub push（ijumori/ppoi） | ✅ | エージェント |
| 8.1 | Apple Developer — Bundle ID 登録 | ✅ | ユーザー |
| 8.2 | App Store Connect — 新規アプリ作成 | ✅ | ユーザー |
| 8.3 | プライバシーポリシー URL 公開 | ✅ | https://ijumori.github.io/ppoi/legal/privacy-policy.html |
| 8.4 | App Privacy（データの収集）申告 | ⬜ | ユーザー（下記テンプレ参照） |
| 8.5 | スクリーンショット（6.7インチ必須） | ⬜ | ユーザー |
| 8.6 | 説明文・キーワード入力 | ⬜ | `app-store-metadata.md` をコピー |
| 8.7 | Xcode Archive → TestFlight | ⬜ | ユーザー |
| 8.8 | 審査提出 | ⬜ | ユーザー |
| 8.9 | Cloud Functions 自動配信（任意） | ⬜ | `cloud-functions-setup.md` |

---

## 8.3 プライバシーポリシー

文案: `docs/legal/privacy-policy.md`  
HTML（公開用）: `docs/legal/privacy-policy.html`

公開後、App Store Connect → **アプリのプライバシー** → プライバシーポリシー URL に貼る。

---

## 8.4 App Privacy（申告の目安）

App Store Connect → **App Privacy** で以下を参考に申告:

| データ | 収集 | 用途 | 第三者 |
|--------|------|------|--------|
| デバイス ID | はい | 広告 | Google（AdMob） |
| 使用状況データ | はい | 広告・分析 | Google |
| 診断データ | はい | クラッシュ（Firebase 利用時） | Google |
| 連絡先・氏名等 | いいえ | — | — |

> アカウント登録なし。格言テキストは Firestore から**読み取りのみ**（端末から個人情報は送信しない）。

**追跡（Tracking）**: AdMob 利用のため「はい」の可能性あり。実際の質問フローに従い、不明なら Google の [AdMob ポリシー](https://support.google.com/admob/answer/6128543) を参照。

---

## 8.5 スクリーンショット

| サイズ | 必須 | 元ネタ |
|--------|------|--------|
| 6.7"（iPhone 15 Pro Max 等） | ✅ 必須 | 実機スクショ or `docs/images/` |
| 6.5" | 推奨 | 同上 |
| 5.5" | 任意 | 同上 |

推奨画面: ホーム / オンボード1 / 共有プレビュー or 設定

---

## 8.7 TestFlight 手順（Xcode）— 詳細

### 事前チェック（5分）

| 確認 | 手順 |
|------|------|
| 署名 | Xcode → PPOI → **Signing & Capabilities** → Team 選択、Automatically manage signing ✅ |
| Bundle ID | `com.takahiro.ppoi` |
| plist 同梱 | **Build Phases → Copy Bundle Resources** に `GoogleService-Info.plist` がある |
| バージョン | **General** → Version `1.0` / Build `1` |
| 実機 | iPhone を接続（Archive はケーブル不要だが推奨） |

### Step 1: Release でビルド設定

1. Xcode 上部の実行先 → **Any iOS Device (arm64)** を選択  
   ※ シミュレータ名が選ばれていると Archive がグレーアウトする
2. メニュー **Product → Scheme → Edit Scheme...**
3. 左 **Archive** → Build Configuration を **Release** にする → Close

### Step 2: Archive 作成

1. **Product → Archive**（または ⇧⌘B のあと Archive）
2. 初回は数分かかる。完了すると **Organizer** が開く
3. 左に今日の日付のアーカイブが表示されれば OK

**よくあるエラー**

| エラー | 対処 |
|--------|------|
| Archive がグレー | 実行先を **Any iOS Device** に変更 |
| Signing failed | Team / Bundle ID を確認 |
| Missing GoogleService-Info | Copy Bundle Resources に追加 |

### Step 3: App Store Connect へアップロード

1. Organizer で最新 Archive を選択
2. **Distribute App** をクリック
3. **App Store Connect** → Next
4. **Upload** → Next
5. オプションは基本デフォルトのまま:
   - Include bitcode: 任意（通常オフで可）
   - Upload symbols: ✅ 推奨
6. **Automatically manage signing** → Next
7. 内容確認 → **Upload**
8. 「Upload Successful」まで待つ

### Step 4: TestFlight で確認

1. [App Store Connect](https://appstoreconnect.apple.com/) → **っぽい格言** → **TestFlight**
2. **ビルド** に新しいビルドが出るまで待つ（**10〜30分**、Processing → Ready）
3. **内部テスト**:
   - 自分をテスターに追加
   - iPhone に **TestFlight** アプリをインストール
   - 招待からインストールして動作確認

### Step 5: 審査提出（TestFlight OK 後）

1. **App Store** タブ → **1.0 の準備をする**
2. 以下を入力済みにする:
   - スクリーンショット（6.7インチ）
   - 説明文（`app-store-metadata.md`）
   - プライバシーポリシー URL
   - サポート URL
   - App Privacy
3. ビルドを選択 → **審査に提出**

### Release ビルドの注意（AdMob）

| ビルド | 広告 |
|--------|------|
| Debug（開発中） | テスト広告のみ（`TEST AD` 表示） |
| **Release（TestFlight / 本番）** | **本番 AdMob ID** が使われる |

> TestFlight 中も **本番広告を自分でクリックしない**（[admob-policy-compliance.md](./admob-policy-compliance.md)）

### 提出前チェックリスト

- [ ] 実行先は **Any iOS Device**
- [ ] Archive は **Release**
- [ ] `GoogleService-Info.plist` 同梱
- [ ] Upload Successful
- [ ] TestFlight で起動・格言表示・共有まで確認

---

## 8.6 メタデータ

`docs/app-store-metadata.md` を参照して App Store Connect にコピペ。

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-20 | 初版 — ASC 登録完了後 |
