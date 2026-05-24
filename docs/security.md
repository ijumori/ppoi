# セキュリティ設計 — っぽい格言

> 更新: 2026-05-20 v2.0
> 方針: **銀行レベル多層防御（Defense in Depth）** — 全23施策を6フェーズで実装

---

## 脅威モデル

| 資産 | 機密度 | 主な脅威 |
|------|--------|----------|
| 格言テキスト（Firestore） | 低（公開コンテンツ） | スクレイピング、API 乱用 |
| 端末キャッシュ | 低 | 脱獄端末からの読み取り |
| ユーザー考察（共有前） | 低 | インジェクション、異常入力 |
| Cloud Functions / Claude API | 高（コスト） | 未認証 HTTP 呼び出し |
| AdMob / Firebase キー | 中 | 第三者 SDK 悪用 |

**扱わないもの**: 決済情報、口座、パスワード、PII（本アプリは非収集）

---

## Phase A: ランタイム保護（5施策）

### A1: DYLD インジェクション検知

| 項目 | 内容 |
|------|------|
| ファイル | `SecurityGuard.swift` |
| 手法 | `_dyld_image_count` + 全ロード済み dylib のスキャン |
| 検知対象 | Frida, Cycript, MobileSubstrate, TweakInject, libhooker, SSLKillSwitch 等 |
| 追加チェック | Frida デフォルトポート（27042）への接続試行 |

### A2: デバッガ接続拒否

| 項目 | 内容 |
|------|------|
| ファイル | `SecurityGuard.swift` |
| 手法 | `ptrace(PT_DENY_ATTACH)` を `dlsym` 経由で呼び出し |
| タイミング | アプリ起動直後（`PPOIApp.init`） |
| 補助 | `sysctl` / `P_TRACED` による二重チェック |

### A3: Frida / Cycript リアルタイム検知

| 項目 | 内容 |
|------|------|
| ファイル | `SecurityGuard.swift` |
| 手法 | ロード済み dylib 名 + ローカルポート接続 |
| 対象 | FridaGadget, frida-agent, libcycript, RevealServer, FLEXLoader 等15ライブラリ |

### A4: コード署名 / Bundle ID 検証

| 項目 | 内容 |
|------|------|
| ファイル | `SecurityGuard.swift` |
| チェック | Bundle ID = `com.takahiro.ppoi` |
| チェック | `_CodeSignature/CodeResources` ファイル存在 |
| チェック | `CFBundleDisplayName` に「っぽい格言」を含む |

### A5: 環境不正時の完全ブロック

| 項目 | 内容 |
|------|------|
| ファイル | `SecurityBlockedView.swift`, `RootView.swift` |
| 動作 | `SecurityGuard.isEnvironmentTrusted == false` → 赤い警告画面を表示しアプリ全機能を遮断 |
| 再チェック | アプリ復帰時（`didBecomeActive`）にも再検証 |

---

## Phase B: データ保護（6施策）

### B1: Keychain アクセス制御強化

| 項目 | 内容 |
|------|------|
| ファイル | `KeychainStore.swift` |
| 変更 | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` → `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` |
| 効果 | パスコード未設定端末ではデータ消去 / iCloud Keychain 同期無効 |
| 追加 | `deleteAll()` メソッド（セキュリティワイプ用） |

### B2: NSFileProtection Complete

| 項目 | 内容 |
|------|------|
| ファイル | `PPOIApp.swift` |
| 対象 | Documents / Library ディレクトリ |
| 効果 | デバイスロック中はアプリデータへのアクセスが不可 |

### B3: SecureLogger（ログ漏洩防止）

| 項目 | 内容 |
|------|------|
| ファイル | `SecureLogger.swift` |
| 手法 | `os.log` + `#if DEBUG` ガード |
| 効果 | Release ビルドで一切のログ出力なし |
| 移行 | 全 `print()` 呼び出しを `SecureLogger` に統一 |

### B4: バックグラウンド スナップショット保護

| 項目 | 内容 |
|------|------|
| ファイル | `RootView.swift` |
| 手法 | `willResignActive` でロック画面オーバーレイを表示 |
| 効果 | アプリスイッチャーに格言内容が表示されない |

### B5: 画面録画検知

| 項目 | 内容 |
|------|------|
| ファイル | `RootView.swift` |
| 手法 | `UIScreen.capturedDidChangeNotification` を監視 |
| 動作 | 録画中はオレンジの警告オーバーレイで画面を隠す |

### B6: クリップボード自動クリア

| 項目 | 内容 |
|------|------|
| ファイル | `ClipboardGuard.swift`, `ShareImageRenderer.swift` |
| 手法 | 共有完了60秒後に `UIPasteboard.general.items = []` |
| 効果 | 格言テキストがクリップボードに残存しない |

---

## Phase C: ネットワーク保護（3施策）

### C1: SSL Pinning 対応 URLSession

| 項目 | 内容 |
|------|------|
| ファイル | `NetworkSecurity.swift` |
| 手法 | `URLSessionDelegate` で公開鍵 SHA-256 ピンニング |
| 構成 | Ephemeral session（キャッシュ/Cookie なし）+ TLS 1.2 最低バージョン |
| 備考 | Firebase SDK は独自 gRPC/TLS を使用するため、カスタム API エンドポイント用に準備 |

### C2: Firebase SDK 通信保護

| 項目 | 内容 |
|------|------|
| 設定 | `NSAllowsArbitraryLoads: false`（ATS 強制） |
| 効果 | HTTP 平文通信を完全禁止 |
| 備考 | Firebase SDK + AdMob SDK は HTTPS 標準通信、App Check トークンが時限式（30分）でリプレイ攻撃を軽減 |

### C3: Release ビルド ログ完全排除

| 項目 | 内容 |
|------|------|
| 対象 | 全 Swift ファイル |
| 手法 | `print()` → `SecureLogger` に統一（Release では無出力） |
| 対象ファイル | InterstitialAdManager, AdMobCompliance, FirebaseBootstrap, SecureQuoteCache |

---

## Phase D: Firebase / バックエンド強化（4施策）

### D1: Firestore Rules フィールド検証

```javascript
match /quotes/{date} {
  allow read: if request.app != null       // App Check 必須
    && isValidDateKey(date)                // YYYY-MM-DD 形式
    && hasRequiredFields();                // text: string(1-500), tone: humorous|serious

  allow write: if false;                   // クライアント書き込み禁止
}

// デフォルト: 全拒否
match /{document=**} {
  allow read, write: if false;
}
```

ファイル: `firestore.rules`

### D2: App Check Enforcement

| 項目 | 内容 |
|------|------|
| 設定場所 | Firebase Console → App Check → API タブ |
| 対象 | Cloud Firestore |
| 状態 | **適用済み** |
| 効果 | App Check トークンなしのリクエストを完全ブロック |

### D3: Firebase API キー制限

| 項目 | 内容 |
|------|------|
| 設定場所 | Google Cloud Console → API とサービス → 認証情報 |
| アプリケーション制限 | iOS アプリ: `com.takahiro.ppoi` |
| API 制限 | Cloud Firestore API, Firebase App Check API, Firebase Installations API |
| 状態 | **設定済み** |

### D4: Cloud Audit Logs

| 項目 | 内容 |
|------|------|
| 設定場所 | Google Cloud Console → IAM と管理 → 監査ログ |
| 対象 | Firestore/Datastore API |
| ログ種類 | 管理読み取り、データ読み取り、データ書き込み（全3種有効） |
| 状態 | **有効化済み** |

---

## Phase E: ビルド / CI セキュリティ（4施策）

### E1: シンボル難読化 / Strip

| 設定 | 値 |
|------|-----|
| `STRIP_INSTALLED_PRODUCT` | YES |
| `STRIP_SWIFT_SYMBOLS` | YES |
| `COPY_PHASE_STRIP` | YES |
| `DEAD_CODE_STRIPPING` | YES |
| `DEPLOYMENT_POSTPROCESSING` | YES (Release) |
| `SWIFT_OPTIMIZATION_LEVEL` | `-O` (Release) |
| `SWIFT_COMPILATION_MODE` | wholemodule (Release) |

### E2: Hardened Runtime

| 設定 | 値 | 効果 |
|------|-----|------|
| `GCC_GENERATE_POSITION_DEPENDENT_CODE` | NO | ASLR 有効 |
| `LD_PIE` | YES | PIE 有効 |
| `-fstack-protector-all` | OTHER_CFLAGS | スタックバッファオーバーフロー保護 |
| `-D_FORTIFY_SOURCE=2` | OTHER_CFLAGS (Release) | バッファオーバーフロー検出 |
| `GCC_WARN_UNINITIALIZED_AUTOS` | YES_AGGRESSIVE | 未初期化変数警告 |

### E3: .gitignore

`.gitignore` で以下を除外:

```
# Secrets
AdMobConfig.plist / GoogleService-Info.plist
*.p12 / *.p8 / *.mobileprovision / *.cer
serviceAccountKey.json / .env / .env.*

# Logs
*.log / crash_reports/
```

### E4: サードパーティキーボード無効化

`Info.plist`: `UIApplicationSupportsThirdPartyKeyboards: false`
→ キーロガー型キーボードによる入力傍受を防止

---

## Phase F: プライバシー / コンプライアンス（2施策）

### F1: PrivacyInfo.xcprivacy

| API | 理由コード |
|-----|-----------|
| UserDefaults | CA92.1 |
| FileTimestamp | C617.1 |

### F2: Release ログ分離

SecureLogger を全コードベースに導入済み（Phase B3 と統合）。

---

## シークレット管理

| ファイル / 値 | 保管場所 |
|--------------|----------|
| `GoogleService-Info.plist` | ローカルのみ（`.gitignore`） |
| `AdMobConfig.plist` | ローカルのみ（`.gitignore`） |
| `ANTHROPIC_API_KEY` | Firebase Secret Manager |
| `MANUAL_QUOTE_SECRET` | Firebase Secret Manager |
| 証明書 (`*.p12`, `*.p8`) | ローカルのみ（`.gitignore`） |

---

## セキュリティファイル一覧

| ファイル | 役割 |
|---------|------|
| `PPOI/Core/Security/SecurityGuard.swift` | A1-A4: ランタイム整合性チェック |
| `PPOI/Core/Security/SecurityBlockedView.swift` | A5: 環境不正時ブロック画面 |
| `PPOI/Core/Security/KeychainStore.swift` | B1: Keychain 暗号化ストレージ |
| `PPOI/Core/Security/SecureQuoteCache.swift` | AES-GCM 暗号化キャッシュ |
| `PPOI/Core/Security/SecureLogger.swift` | B3/C3/F2: Release 安全ログ |
| `PPOI/Core/Security/ClipboardGuard.swift` | B6: クリップボード自動クリア |
| `PPOI/Core/Security/NetworkSecurity.swift` | C1: SSL Pinning URLSession |
| `PPOI/Core/Security/InputSanitizer.swift` | 入力サニタイズ |
| `firestore.rules` | D1: Firestore セキュリティルール |

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-20 | v2.0 — 銀行レベル全23施策実装（6フェーズ完了） |
| 2026-05-20 | v1.0 — 初版: App Check, Keychain, SecurityGuard, Functions 認証 |
