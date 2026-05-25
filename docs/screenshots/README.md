# App Store スクリーンショット素材

> 6.7インチ（1290×2796）推奨。`./scripts/ios/generate-screenshots.sh` で再生成可能。

## 一覧

| ファイル | 内容 | ASC 用途 |
|----------|------|----------|
| `01-onboarding1.png` | オンボード1 | ✅ |
| `02-home_clean.png` | ホーム（今日の一句） | ✅ 推奨 |
| `03-settings_clean.png` | 設定 | 任意 |
| `06-share-preview.png` | 共有プレビュー（カード＋投稿テキスト＋𝕏ボタン） | ✅ 共有フロー |
| `07-share-input.png` | 考察入力画面 | 任意 |
| `04-share-card-with-reflection.png` | **𝕏投稿画像** 1200×675（考察あり） | 参考・宣伝 |
| `05-share-card-quote-only.png` | 𝕏投稿画像（考察なし） | 参考 |
| `08-x-timeline-mock.png` | 𝕏タイムライン風モック（投稿イメージ） | ✅ 共有フロー |

## 共有フローで作られる画像

1. **アプリ内プレビュー**（`06`）… `SharePreviewView`  
2. **𝕏に添付される画像**（`04` / `05`）… `ShareCardExportView` 1200×675・16:9  
3. **投稿テキスト** … `私の考察：…` + `#っぽい格言`（画像には含まれない）

## 再生成

```bash
./scripts/ios/generate-screenshots.sh
```

## App Store Connect へ自動アップロード

```bash
./scripts/ios/upload-asc.sh
```

`fastlane deliver` で **6.7インチ（APP_IPHONE_67）** に4枚＋メタデータ（マーケティング URL 等）を登録。
