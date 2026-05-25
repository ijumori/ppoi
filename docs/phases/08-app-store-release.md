# Phase 8: App Store リリース準備 — っぽい格言

> 更新: 2026-05-25
> Bundle ID: `com.takahiro.ppoi`
> App Store Connect: 登録済み ✅
> ステータス: **審査待ち** (v1.0.0 Build 3)

---

## 進捗チェックリスト

| # | 項目 | 状態 | 担当 |
|---|------|------|------|
| 8.0 | GitHub push（ijumori/ppoi） | ✅ | エージェント |
| 8.1 | Apple Developer — Bundle ID 登録 | ✅ | ユーザー |
| 8.2 | App Store Connect — 新規アプリ作成 | ✅ | ユーザー |
| 8.3 | プライバシーポリシー URL 公開 | ✅ | https://ijumori.github.io/ppoi/legal/privacy-policy.html |
| 8.4 | App Privacy（データの収集）申告 | 🟡 | ASC Web画面で手動設定 |
| 8.5 | スクリーンショット（6.7インチ必須） | ✅ | fastlane deliver でアップロード済（2枚: オンボーディング・ホーム） |
| 8.6 | 説明文・キーワード入力 | ✅ | fastlane deliver でアップロード済 |
| 8.7 | Archive → Upload → App Store | ✅ | **1.0.0 (3)** Upload済・審査用ビルド選択済 |
| 8.8 | 審査提出 | ✅ **審査待ち** | 2026-05-25 提出 |
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
| 6.7"（iPhone 15 Pro Max 等） | ✅ 必須 | 実機スクショ or `docs/design/` |
| 6.5" | 推奨 | 同上 |
| 5.5" | 任意 | 同上 |

推奨画面: ホーム / オンボード1 / 共有プレビュー or 設定

---

## 8.7 TestFlight

### いまの状態（2026-05-25 時点）

| 項目 | 状態 |
|------|------|
| ASC「ビルドのアップロード」 | ✅ **1.0.0 (3)**・終了 |
| 輸出コンプライアンス | ✅ 申告済み |
| メタデータ | ✅ fastlane deliver でアップロード済 |
| スクリーンショット | ✅ 6.7" × 2枚アップロード済 |
| 年齢レーティング | 🟡 ASC Webで手動設定が必要 |
| **App Store 審査** | 🟡 **審査待ち** |

**CURRENT_PROJECT_VERSION**: 現在 **3**。次回 Upload 時は **4** に上げる。

**過去の不具合・修正**

| 問題 | 対処 |
|------|------|
| Upload 90474（iPad 向き） | `TARGETED_DEVICE_FAMILY = 1`（iPhone のみ）→ §8.7.7 で pbxproj 修正済み |
| 「Build 2」と誤認 | `Info.plist` だけ変更しても無効。**ターゲット**の `CURRENT_PROJECT_VERSION` が ASC のビルド番号になる |
| ASC にアプリは見えるが TestFlight に出ない | ビルドが **審査待ち** の間は配布不可 |

---

### 8.7.1 ステップバイステップ（推奨フロー）

各ステップ完了後、次に進む。詳細は会話ログまたは本節のトラブルシュートを参照。

| Step | 内容 | 完了の目安 |
|------|------|------------|
| 1 | ASC → **っぽい格言** → **TestFlight** → iOS | **ビルドのアップロード** に **1.0.0 (1)** が見える |
| 2 | **バージョン 1.0.0** のビルド **1** → **管理**（輸出コンプライアンス） | 申告保存済み（ステータスが **審査待ち** または **テスト可能**） |
| 3 | **内部テスト** → グループに **1.0.0 (1)** を追加 | グループにビルドが紐づく |
| 4 | iPhone に **TestFlight** アプリをインストール、Apple ID を ASC と揃える | 準備完了 |
| 5 | ビルド **1** が **テスト可能** になるまで待つ（24〜48h） | 黄色警告・審査待ちが消える |
| 6 | TestFlight で **っぽい格言** → **インストール** | ホーム画面にアイコン |
| 7 | 実機チェック（格言・共有・設定） | `docs/phases/07-testing-checklist.md` 相当 |
| 8 | §8.4〜8.6 完了後、**審査に提出** | App Store タブから提出 |

---

### 8.7.2 輸出コンプライアンス（暗号化申告）

**場所**: TestFlight → **バージョン 1.0.0** → ビルド **1** → **管理**

#### 質問「アプリに暗号化は使用していますか？」

| 選択 | っぽい格言 |
|------|------------|
| **いいえ** | ✅ 推奨（HTTPS / Firebase / AdMob の標準 API のみ） |
| はい | 追加質問へ。書類提出を選ぶと **審査待ち** が長くなる |

#### 4つの画像（暗号化書類の種類）だけ出る場合

| 選ぶ | ラベルの例 |
|------|------------|
| ✅ 1位 | **暗号化を使用しない** |
| ✅ 2位 | **免除される暗号化のみ** / 標準的な暗号のみ |
| ❌ | **独自の暗号化** |
| ❌ | **書類を提出** / コンプライアンス書類のアップロード |

#### ステータス別の動き

| ASC のステータス | TestFlight（iPhone） | やること |
|------------------|----------------------|----------|
| **コンプライアンスがありません** | 出ない | **管理** で上記を申告 |
| **審査待ち** | **出ない**（正常） | 24〜48h 待つ。内部テストのテスター追加は先に可 |
| **テスト可能** | **出る** | TestFlight からインストール |
| **処理中** | 出ない | Upload 後 10〜30 分待つ |

---

### 8.7.3 トラブルシューティング

#### ASC（ブラウザ）にはアプリがあるが、TestFlight アプリに出ない

1. ビルド **1** のステータスを確認 → **審査待ち** なら **待つだけ**
2. iPhone の **設定 → Apple ID** が ASC ログインと**同じ**か確認
3. **内部テスト** → グループ → **テスター** に iPhone のメールを追加
4. **テスト可能** になったら TestFlight アプリを再起動

#### 48時間以上「審査待ち」のまま

- 申告で **書類提出** / **はい（独自暗号）** を選んでいないか確認
- ASC サポートまたは再申告（**管理** から修正できる場合あり）
- 急ぎの実機確認は Xcode から実機 **Release** 実行でも可（TestFlight 以外）

---

### 8.7.4 ビルド番号の上げ方（再 Upload 時）

**正**: Xcode → ターゲット **PPOI** → **Build Settings** → `Current Project Version`  
（`project.pbxproj` のターゲット `CURRENT_PROJECT_VERSION`。次回 Upload 用は **2** に設定済み）

**誤**: `Info.plist` の `CFBundleVersion` だけ変更（上書きされる）

`Info.plist` は次の変数参照に統一:

```xml
<key>CFBundleShortVersionString</key>
<string>$(MARKETING_VERSION)</string>
<key>CFBundleVersion</key>
<string>$(CURRENT_PROJECT_VERSION)</string>
```

再 Upload 手順:

1. `CURRENT_PROJECT_VERSION` を未使用の整数に **+1**
2. `./scripts/ios/testflight-upload.sh` または Xcode Archive → Upload
3. ASC で新しい **(n)** が **終了** → コンプライアンス → 内部テストに追加

---

### 8.7.5 方法 A: CLI 自動 Upload

```bash
cd "/Users/takahironishii/マイドライブ（ijumorimori@gmail.com）/04.Dev/PPOI"
./scripts/ios/testflight-upload.sh
```

| 項目 | 内容 |
|------|------|
| スクリプト | `scripts/ios/testflight-upload.sh` |
| 設定 | `ExportOptions.plist`（`app-store-connect` + upload） |
| Team | `NXFZ5AUX62` |
| デバイス | iPhone のみ（`TARGETED_DEVICE_FAMILY = 1`） |

**dSYM 警告**（Firebase / AdMob）: 警告のみ。Upload は成功する。

---

### 8.7.6 方法 B: Xcode GUI（手動）

#### 事前チェック

| # | 項目 |
|---|------|
| 1 | 実行先 **Any iOS Device (arm64)** |
| 2 | Archive = **Release**（Edit Scheme） |
| 3 | `GoogleService-Info.plist` が Copy Bundle Resources にある |
| 4 | `CURRENT_PROJECT_VERSION` が ASC 未使用の番号 |

#### Archive → Upload

1. **Product → Archive**
2. Organizer → **Distribute App** → App Store Connect → **Upload**
3. ASC → TestFlight で **1.0.0 (n)** の **終了** を確認

#### 内部テスト → 実機

1. **内部テスト** → ビルド **1.0.0 (1)** をグループに追加
2. **テスト可能** 後、iPhone の TestFlight からインストール
3. 起動・格言・共有・設定を確認

---

### 8.7.7 iPhone のみ（iPad スクショ不要）

ASC に **iPad 用スクリーンショットを求めない** には、バイナリを **iPhone のみ** にする。ASC 単体で iPad をオフにする設定はない。

| 層 | 設定 |
|----|------|
| `project.yml` | 全体・ターゲット **PPOI** / **PPOIScreenshotTests** で `TARGETED_DEVICE_FAMILY: "1"` |
| Xcode 反映 | `xcodegen generate`（`PPOI.xcodeproj` の `"1,2"` を `"1"` に揃える） |
| `Info.plist` 生成結果 | `UIDeviceFamily` = **1 のみ**（ビルド後に確認） |
| ASC | iPhone サイズのみアップロード。iPad タブは**空のまま**可 |
| 審査用ビルド | **iPhone のみの新ビルド**に差し替え（古い Universal ビルドが紐づくと iPad 欄が残る） |

#### 確認コマンド（ビルド後）

```bash
/usr/libexec/PlistBuddy -c "Print UIDeviceFamily" \
  "$(xcodebuild -showBuildSettings -scheme PPOI -configuration Release 2>/dev/null \
    | awk -F' = ' '/TARGET_BUILD_DIR/{d=$2} /FULL_PRODUCT_NAME/{n=$2} END{print d"/"n}')/Info.plist"
```

期待値: `Array { 1 }`（`2` が含まれていたら `xcodegen generate` を再実行）

#### 再 Upload 手順

1. `CURRENT_PROJECT_VERSION` を未使用番号に +1（§8.7.4）
2. `xcodegen generate` → `./scripts/ios/testflight-upload.sh`
3. ASC → **App Store** → バージョン → 審査用ビルドを新 **(n)** に変更
4. **メタデータ**で iPad タブが消えた／必須でなくなったことを確認

参考: [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)（*Required if app runs on iPad*）

---

### Release ビルドの注意（AdMob）

| ビルド | 広告 |
|--------|------|
| Debug | テスト広告（`TEST AD`） |
| **Release（TestFlight / 本番）** | **本番 AdMob ID** |

> TestFlight 中も **本番広告を自分でクリックしない**（[admob-policy-compliance.md](../guides/admob-policy-compliance.md)）

---

### TestFlight 提出前チェックリスト

- [x] Archive（Release）・Upload **1.0.0 (3)**
- [x] 輸出コンプライアンス申告
- [x] 内部テストにビルド追加
- [x] iPhone のみビルド（`TARGETED_DEVICE_FAMILY = 1`）
- [x] スクショ（fastlane deliver・6.7" × 2枚）
- [x] メタデータ（fastlane deliver）
- [x] App Store 審査提出（2026-05-25）
- [ ] 年齢レーティング（ASC Web で手動設定）
- [ ] App Privacy（ASC Web で手動設定）
- [ ] 審査通過・公開

---

## 8.6 メタデータ

`docs/app-store-metadata.md` を参照して App Store Connect にコピペ。

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-20 | 初版 — ASC 登録完了後 |
| 2026-05-20 | §8.7 CLI・Build 番号の注意 |
| 2026-05-20 | 実態反映: (1) のみ・審査待ち・ステップバイステップ・トラブルシュート・CURRENT_PROJECT_VERSION |
| 2026-05-20 | §8.7.7 iPhone のみ（TARGETED_DEVICE_FAMILY・xcodegen・UIDeviceFamily 確認） |
| 2026-05-25 | ビルド3アップロード・fastlane deliver でメタデータ＋スクショ投入・審査提出 |
