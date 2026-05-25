# プロジェクト初期化 — っぽい格言

> Phase 5: Xcode プロジェクト設定

## §1 識別子

| 項目 | 値 |
|------|-----|
| アプリ表示名 | っぽい格言 |
| プロジェクト名 | PPOI |
| Bundle ID | `com.takahiro.ppoi` |
| 最小 iOS | 17.0 |

**確定**: ✅

---

## §2 プロジェクト構成（最適化後）

```
ppoi/
├── project.yml              # xcodegen
├── PPOI.xcodeproj/
├── PPOI/                    # iOS アプリ
│   ├── App/
│   ├── Features/
│   ├── Core/
│   │   ├── Data/
│   │   ├── Persistence/
│   │   ├── Infrastructure/
│   │   └── Security/
│   ├── DesignSystem/
│   └── Resources/
├── docs/
│   ├── phases/              # 00〜08
│   ├── guides/
│   ├── design/
│   ├── screenshots/
│   └── legal/               # GitHub Pages（パス固定）
├── config/
│   ├── ios/
│   └── firebase/
├── functions/
├── scripts/ios/
└── fastlane/
```

**ビルド確認**: ✅ `xcodegen generate` → Simulator / 実機

---

## Phase 5 完了 ✅

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-19 | P5-Q2 — Bundle ID `com.takahiro.ppoi` |
| 2026-05-20 | ディレクトリ構成を phases/guides/config に整理 |
