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

**v1.3.0 (Build 11) — App Store 提出前・リファクタリング進行中**

- v1.0 (Build 8): Guideline 4.2 却下（最低限機能）
- v1.2: 3タブ構成・iPad対応・AI解読・Explore・MyPage 実装済み
- v1.3: 一句日記 / カレンダー / 実績8種 / 週間ランキング / freeLimit=10 実装済み
- v2.0: 買い切り課金 StoreKit 2 実装済み
- リファクタリング: Phase 0・1・2 完了（`docs/refactoring-plan.md`）/ Phase 3〜5 進行中
- 次アクション: v1.3 を App Store Connect に提出
