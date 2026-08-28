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

## Claude Code スキル

Cursor ルールと並行して、Claude Code 用のプロジェクトスキルを `.claude/skills/` に用意している。

| スキル | 対応役割 | 用途 |
|--------|----------|------|
| `ios-build` | iOS Dev | `xcodegen generate` → ビルド |
| `ios-test` | QA | ユニット/スクショテスト + Cloud Functions テスト |
| `ios-release` | Release | ビルド番号 +1 → Archive → ASC アップロード（submit は要確認） |

プロジェクト全体の前提・コマンドは [CLAUDE.md](CLAUDE.md) にまとめている。

## 現在フェーズ

最新状況は [CLAUDE.md](CLAUDE.md) の「現在フェーズ」を参照(このファイルでは重複保持しない)。
