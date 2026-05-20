# 「っぽい格言」iOSアプリ 開発手順書

## 進め方

1. **要件定義**（現在）— 一問一答で `docs/01-requirements.md` を埋める
2. **コンセプト・体験設計** — 画面フロー、主要ユースケース
3. **UI/UX設計** — ワイヤー、デザイン方針、コピー
4. **技術選定** — SwiftUI / データ保存 / API の決定
5. **プロジェクト初期化** — Xcode プロジェクト作成
6. **MVP実装** — 最小機能を縦に通す
7. **テスト・品質確認** — 実機確認、エッジケース
8. **リリース準備** — App Store 素材、プライバシーポリシー

各フェーズ完了時にチェックリストを更新し、次フェーズへ進む。

---

## フェーズ詳細

### Phase 1: 要件定義

| # | 項目 | 成果物 | 状態 |
|---|------|--------|------|
| 1.1 | アプリの目的・一言説明 | requirements.md §1 | ✅ |
| 1.2 | ターゲットユーザー | requirements.md §2 | ✅ |
| 1.3 | コア機能（Must / Should / Won't） | requirements.md §3 | ✅ |
| 1.4 | 格言の生成方式（AI / 固定 / ハイブリッド） | requirements.md §4 | ✅ |
| 1.5 | 画面一覧 | requirements.md §5 | ✅ |
| 1.6 | 収益化・課金 | requirements.md §6 | ✅ |
| 1.7 | 非機能要件（オフライン、言語等） | requirements.md §7 | ✅ |
| 1.8 | 制約・スコープ外 | requirements.md §8 | ✅ |

### Phase 2: コンセプト・体験設計 ✅

- ユーザージャーニー（起動 → 格言表示 → 共有/保存）
- トーン＆マナー（「っぽさ」の定義）
- オンボーディング・テーマ3択・共有画像方針
- 成果物: `docs/02-experience-design.md`

### Phase 3: UI/UX設計 ✅

- 操作フロー、カラートークン、アニメーション
- 成果物: `docs/03-ui-design.md`

### Phase 4: 技術選定 ✅

- Firebase + Claude + UserDefaults
- 成果物: `docs/04-tech-stack.md`

### Phase 5: プロジェクト初期化 ✅

- Xcode プロジェクト作成（`PPOI.xcodeproj`）
- 成果物: `docs/05-project-setup.md`, `README.md`

### Phase 6: MVP実装

### Phase 6: MVP実装 ✅

| 順序 | 機能 | 状態 |
|------|------|------|
| 6.1 | Firestore 格言取得 | ✅ |
| 6.2 | 共有画像 + ShareSheet | ✅ |
| 6.3 | Cloud Functions + Claude | ✅ |
| 6.4 | AdMob 広告 | ✅ |

### Phase 7: テスト ✅

- 実機テスト完了（`docs/07-testing-checklist.md`）
- v1.1 改善予定: 共有画像の改行位置

### Phase 8: リリース

- App Store Connect 設定
- スクリーンショット・説明文
- プライバシーポリシー

---

## 役割別エージェント

| 役割 | ルールファイル | 主な責務 |
|------|----------------|----------|
| プロダクトオーナー | `.cursor/rules/agent-product-owner.mdc` | 要件、優先度、スコープ |
| UI/UXデザイナー | `.cursor/rules/agent-uiux-designer.mdc` | 画面設計、ビジュアル、コピー |
| iOS開発者 | `.cursor/rules/agent-ios-developer.mdc` | SwiftUI 実装、アーキテクチャ |
| QA | `.cursor/rules/agent-qa.mdc` | テスト観点、バグ報告 |
| リリース担当 | `.cursor/rules/agent-release.mdc` | App Store、法務・プライバシー |

エージェント切り替え例:
- 要件の議論 → `@agent-product-owner`
- 画面デザイン → `@agent-uiux-designer`
- 実装 → `@agent-ios-developer`

---

## 現在の進捗

- **フェーズ**: Phase 8 — リリース準備
- **Phase 1〜7**: ✅ 完了
- **Phase 8**: Bundle ID + ASC 登録 ✅
- **次**: P8-Q5（Archive / Upload 完了確認）
- **8.3 Pages**: ✅ https://ijumori.github.io/ppoi/legal/privacy-policy.html
- **成果物**: `docs/08-app-store-release.md`, `docs/legal/`, `docs/app-store-metadata.md`
- **更新日**: 2026-05-19
