# スクリプト

| パス | 内容 |
|------|------|
| [ios/testflight-upload.sh](ios/testflight-upload.sh) | Archive → App Store Connect アップロード |
| [ios/upload-asc.sh](ios/upload-asc.sh) | スクショ＋メタデータを ASC に登録（deliver） |
| [ios/sync-asc-screenshots.sh](ios/sync-asc-screenshots.sh) | docs/screenshots → fastlane 同期 |
| [ios/generate-screenshots.sh](ios/generate-screenshots.sh) | スクショ PNG 生成 |

```bash
./scripts/ios/testflight-upload.sh
```

手順: [docs/phases/08-app-store-release.md](../docs/phases/08-app-store-release.md) §8.7
