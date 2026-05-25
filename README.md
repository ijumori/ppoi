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

## リポジトリ構成

```
PPOI/                    # iOS アプリ（SwiftUI）
├── App/                 # エントリ・ルート
├── Features/            # 画面（Quote, Share, Settings, Onboarding, Ads）
├── Core/
│   ├── Data/            # モデル・Repository・QuoteService
│   ├── Persistence/     # UserDefaults
│   ├── Infrastructure/  # Firebase, AdMob, 通知
│   └── Security/        # App Check, Keychain, ランタイム保護
├── DesignSystem/
└── Resources/

docs/
├── phases/              # 00〜08 開発フェーズ
├── guides/              # Firebase, AdMob, セキュリティ, リリース
├── design/              # UI 参照画像
├── screenshots/         # App Store 素材
└── legal/               # プライバシーポリシー（GitHub Pages）

config/
├── ios/                 # ExportOptions.plist
└── firebase/            # firestore.rules

functions/               # Cloud Functions
scripts/ios/             # TestFlight アップロード
fastlane/                # App Store メタデータ
```

## セキュリティ

多層防御を実装。詳細は [docs/guides/security.md](docs/guides/security.md)。

## ドキュメント

- [索引](docs/README.md)
- [開発手順](docs/phases/00-development-process.md)
- [要件定義](docs/phases/01-requirements.md)
- [TestFlight / リリース](docs/phases/08-app-store-release.md)

## Bundle ID

`com.takahiro.ppoi`
