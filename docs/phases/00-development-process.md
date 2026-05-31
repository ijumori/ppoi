# 「っぽい格言」iOSアプリ 開発手順書

## 進め方

1. **要件定義**（現在）— 一問一答で `docs/phases/01-requirements.md` を埋める
2. **コンセプト・体験設計** — 画面フロー、主要ユースケース
3. **UI/UX設計** — ワイヤー、デザイン方針、コピー
4. **技術選定** — SwiftUI / データ保存 / API の決定
5. **プロジェクト初期化** — Xcode プロジェクト作成
6. **MVP実装** — 最小機能を縦に通す
7. **テスト・品質確認** — 実機確認、エッジケース
8. **リリース準備** — App Store 素材、プライバシーポリシー

各フェーズ完了時にチェックリストを更新し、次フェーズへ進む。

> 次バージョンに向けた企画・要件の再設計は [`docs/redesign/`](../redesign/00-overview.md) を参照（出荷版 v1 の記録は本フォルダに保持）。

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
- 成果物: `docs/phases/02-experience-design.md`

### Phase 3: UI/UX設計 ✅

- 操作フロー、カラートークン、アニメーション
- 成果物: `docs/phases/03-ui-design.md`

### Phase 4: 技術選定 ✅

- Firebase + Claude + UserDefaults
- 成果物: `docs/phases/04-tech-stack.md`

### Phase 5: プロジェクト初期化 ✅

- Xcode プロジェクト作成（`PPOI.xcodeproj`）
- 成果物: `docs/phases/05-project-setup.md`, `README.md`

### Phase 6: MVP実装

### Phase 6: MVP実装 ✅

| 順序 | 機能 | 状態 |
|------|------|------|
| 6.1 | Firestore 格言取得 | ✅ |
| 6.2 | 共有画像 + ShareSheet | ✅ |
| 6.3 | Cloud Functions + Claude | ✅ |
| 6.4 | AdMob 広告 | ✅ |

### Phase 7: テスト ✅

- 実機テスト完了（`docs/phases/07-testing-checklist.md`）
- v1.1 改善予定: 共有画像の改行位置

### Phase 8: リリース 🟡 進行中

| 項目 | 状態 |
|------|------|
| Bundle ID・ASC アプリ | ✅ |
| プライバシーポリシー URL | ✅ |
| TestFlight Upload **1.0.0 (1)** | ✅ |
| 輸出コンプライアンス | 🟡 審査待ち |
| TestFlight 実機確認 | ⬜ テスト可能後 |
| セキュリティ強化（App Check 等） | 🟡 コード済 — Firebase Console 設定待ち |
| スクショ・メタデータ・審査提出 | ⬜ |

詳細: `docs/phases/08-app-store-release.md` §8.7 / `docs/guides/security.md`

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

- **フェーズ**: Phase 8 — リリース準備 + 次バージョン開発
- **Phase 1〜7**: ✅ 完了
- **Phase 8**: TestFlight **1.0.0 (1)** Upload済・輸出コンプライアンス **審査待ち**
- **8.3 Pages**: ✅ https://ijumori.github.io/ppoi/legal/privacy-policy.html

### 再設計・次バージョン（`docs/redesign/`）

- **再設計**: 企画・要件をガイド準拠でゼロベース再構築（ペルソナ/競合/収益/MVP/WBS）
- **v1.1**: ✅ 実装済 — 創作明示 / お気に入り / ストリーク（`docs/redesign/v1.1-design.md`）
- **v1.2**: ✅ 実装済 — 今日の格言ウィジェット（`docs/redesign/v1.2-design.md`）
- **v2.0**: ✅ 実装済 — 買い切り課金 StoreKit 2（`docs/redesign/v2.0-design.md`）
- **WBS**: W1〜W8 全タスク実装完了
- **要対応（Mac/ASC）**: `xcodegen generate` → ビルド/実機・Sandbox確認 / App Groups `group.com.takahiro.ppoi` 有効化 / IAP `com.takahiro.ppoi.premium`(¥400) 作成 → 詳細は [`docs/redesign/next-steps.md`](../redesign/next-steps.md)
- **更新日**: 2026-06-01
