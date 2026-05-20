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

## 8.7 TestFlight 手順（Xcode）

1. Xcode → **Product → Archive**（Release / Any iOS Device）
2. **Organizer** → **Distribute App** → **App Store Connect** → Upload
3. App Store Connect → **TestFlight** → ビルド処理完了を待つ（10〜30分）
4. **内部テスト** または **外部テスト** で実機確認
5. 問題なければ **審査に提出**

### 提出前の Release 確認

- [ ] Debug ではない **Release** ビルド
- [ ] `GoogleService-Info.plist` 同梱
- [ ] AdMob は本番 ID（Release 時のみ。開発中はテスト ID のまま）
- [ ] バージョン `1.0 (1)`

---

## 8.6 メタデータ

`docs/app-store-metadata.md` を参照して App Store Connect にコピペ。

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-20 | 初版 — ASC 登録完了後 |
