# プロジェクト初期化 — っぽい格言

> Phase 5: Xcode プロジェクト設定

## §1 識別子

**P5-Q2**: Bundle ID・プロジェクト名

| 項目 | 値 |
|------|-----|
| アプリ表示名 | っぽい格言 |
| プロジェクト名 | PPOI |
| Bundle ID | `com.takahiro.ppoi` |
| 最小 iOS | 17.0 |

**確定**: ✅

---

## §2 プロジェクト構成

```
PPOI/
├── project.yml          # xcodegen 設定
├── PPOI.xcodeproj       # 生成済み
├── PPOI/
│   ├── App/
│   ├── Features/        # Quote, Share, Settings, Onboarding
│   ├── Core/
│   ├── DesignSystem/
│   └── Resources/
└── docs/
```

**ビルド確認**: ✅ iPhone 17 Simulator

---

## Phase 5 完了 ✅

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-19 | P5-Q2 — Bundle ID `com.takahiro.ppoi` |
