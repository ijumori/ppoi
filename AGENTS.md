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

**v1.3.0 (Build 12) — App Store 審査提出済み（2026-07-23・WAITING_FOR_REVIEW）**

- v1.0 (Build 8): Guideline 4.2 却下（最低限機能）
- v1.2: 3タブ構成・iPad対応・AI解読・Explore・MyPage 実装済み
- v1.3: 一句日記 / カレンダー / 実績8種 / 週間ランキング / freeLimit=10 実装済み
- v2.0: 買い切り課金 StoreKit 2 実装済み
- リファクタリング: Phase 0〜3 完了・Phase 4/5 一部（`docs/refactoring-plan.md`）
- 提出: Build 12 を再 Archive→アップロード、iPad/iPhone スクショ登録、旧却下 submission を解放して提出（`fastlane submit_v13`）
- 次アクション: 審査結果を待つ。リジェクト時は Skill `asc-reject`
