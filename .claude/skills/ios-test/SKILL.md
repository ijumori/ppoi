---
name: ios-test
description: PPOI(っぽい格言)のユニット/スクショテストと Cloud Functions テストを実行する。「テストして」「テスト通るか」「QAとして確認」「ファンクションのテスト」と言われたら使う。
---

# ios-test — PPOI テスト

## iOS ユニット / スクショテスト

```bash
xcodebuild -scheme PPOI \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

- ユニット: `PPOITests/`（QuoteService / QuoteViewModel / ShareCardFontSize / UserDefaultsStore）
- スクショ: `PPOIScreenshotTests/`（App Store 素材の書き出し）
- 特定ターゲットのみ: `-only-testing:PPOITests` を付ける。
- 特定ケースのみ: `-only-testing:PPOITests/QuoteServiceTests/testXxx`。

## Cloud Functions テスト

```bash
cd functions && npm test        # vitest run
```

## 進め方

1. まず失敗の有無を確認し、出力の failure 行を特定する。
2. 失敗したら該当テストと実装コードを読み、原因を切り分ける（テスト側の期待値か実装バグか）。
3. 修正後に同じテストだけ再実行 → 全体再実行の順で確認する。
4. テストが落ちているのに「通った」と報告しない。落ちたら出力とともに事実を伝える。
