# PPOI — っぽい格言

日付同期の「っぽい格言」iOSアプリ。

## セットアップ

```bash
# Xcode プロジェクト生成
xcodegen generate

# ビルド
xcodebuild -scheme PPOI -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Xcode で `PPOI.xcodeproj` を開く。

## 構成

| パス | 内容 |
|------|------|
| `PPOI/App/` | エントリポイント |
| `PPOI/Features/` | 画面（Quote, Share, Settings, Onboarding） |
| `PPOI/Core/Models/` | データモデル |
| `PPOI/Core/Services/` | Firebase, AdMob, 通知 |
| `PPOI/Core/Security/` | セキュリティ（8ファイル） |
| `PPOI/DesignSystem/` | 3テーマカラー |
| `docs/` | 要件・設計ドキュメント |

## セキュリティ

銀行レベル多層防御を実装（全23施策 / 6フェーズ）。詳細は [docs/security.md](docs/security.md)。

| フェーズ | 内容 | 施策数 |
|---------|------|--------|
| A: ランタイム保護 | 脱獄/デバッガ/DYLD注入/署名検証/完全ブロック | 5 |
| B: データ保護 | Keychain強化/ファイル保護/スナップショット/録画検知/クリップボード | 6 |
| C: ネットワーク | SSL Pinning/ATS/ログ排除 | 3 |
| D: Firebase | Firestore Rules/App Check Enforcement/APIキー制限/監査ログ | 4 |
| E: ビルド強化 | シンボルstrip/ASLR/スタック保護/gitignore | 4 |
| F: プライバシー | PrivacyInfo/SecureLogger | 2 |

## ドキュメント

- [開発手順](docs/00-development-process.md)
- [要件定義](docs/01-requirements.md)
- [体験設計](docs/02-experience-design.md)
- [UI設計](docs/03-ui-design.md)
- [技術選定](docs/04-tech-stack.md)
- [セキュリティ設計](docs/security.md)

## Bundle ID

`com.takahiro.ppoi`
