# エージェント一覧 — っぽい格言

このプロジェクトでは役割ごとに Cursor ルールを切り替えて開発する。

## 使い方

Cursor で該当ルールを有効にするか、会話で役割を指定する:

> 「プロダクトオーナーとして Q1 に答えたい」
> 「iOS開発者として MVP を実装して」

## エージェント

| 役割 | ルール | いつ使うか |
|------|--------|------------|
| プロダクトオーナー | `agent-product-owner.mdc` | 要件定義、優先度、スコープ |
| UI/UXデザイナー | `agent-uiux-designer.mdc` | 画面設計、見た目、コピー |
| iOS開発者 | `agent-ios-developer.mdc` | SwiftUI 実装 |
| QA | `agent-qa.mdc` | テスト、バグ確認 |
| リリース担当 | `agent-release.mdc` | App Store 公開 |

## 開発の流れ

```
PO（要件）→ UI/UX（設計）→ iOS Dev（実装）→ QA（テスト）→ Release（公開）
```

詳細は [docs/phases/00-development-process.md](docs/phases/00-development-process.md) を参照。

## 現在フェーズ

**運用・改善（v1 リリース準備 + 次バージョン開発）**

- v1.0.0: App Store 審査段階（`docs/phases/08-app-store-release.md`）
- 企画・要件の再設計を実施（`docs/redesign/`）
- v1.1（創作明示・お気に入り・ストリーク）/ v1.2（今日の格言ウィジェット）実装済み
- 次: v2.0 買い切り課金（W5〜W8）／実機ビルド確認
