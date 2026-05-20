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

詳細は [docs/00-development-process.md](docs/00-development-process.md) を参照。

## 現在フェーズ

**Phase 1: 要件定義** — プロダクトオーナーが一問一答で進行中
