# PPOI — っぽい格言

日付同期の「っぽい格言」iOSアプリ。

## セットアップ

```bash
# Xcode プロジェクト生成
xcodegen generate

# ビルド
xcodebuild -scheme PPOI -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Xcode で `PPOI.xcodeproj` を開く。

## 構成

| パス | 内容 |
|------|------|
| `PPOI/App/` | エントリポイント |
| `PPOI/Features/` | 画面（Quote, Share, Settings, Onboarding） |
| `PPOI/Core/` | Models, Services |
| `PPOI/DesignSystem/` | 3テーマカラー |
| `docs/` | 要件・設計ドキュメント |

## ドキュメント

- [開発手順](docs/00-development-process.md)
- [要件定義](docs/01-requirements.md)
- [体験設計](docs/02-experience-design.md)
- [UI設計](docs/03-ui-design.md)
- [技術選定](docs/04-tech-stack.md)

## Bundle ID

`com.takahiro.ppoi`

## Phase 6 TODO

- [ ] Firebase Firestore 連携
- [ ] Cloud Functions（Claude API）
- [ ] 共有画像の ImageRenderer 生成
- [ ] AdMob バナー + インタースティシャル
- [ ] ShareLink（𝕏）
