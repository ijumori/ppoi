---
name: ios-release
description: PPOI(っぽい格言)を Archive→TestFlight/App Store Connect にアップロード・審査提出する準備を支援する。「リリース準備」「TestFlightに上げる」「ビルド番号上げて」「ASCにアップ」「審査提出」と言われたら使う。publish は自動でしない。
---

# ios-release — PPOI リリース

⚠️ **App Store への提出・公開は外部送信。実行前に必ずユーザーの明示的確認を取る。** このスキルは準備・アップロードまでで、審査提出（submit）は確認後にのみ行う。

## 1. ビルド番号を上げる（再アップロード時は必須）

`project.yml` の `CURRENT_PROJECT_VERSION` を +1 → 再生成。
（Info.plist だけ変えても ASC のビルド番号は変わらない。）

```bash
# project.yml: CURRENT_PROJECT_VERSION を +1、必要なら MARKETING_VERSION も更新
xcodegen generate
```

## 2. Archive → App Store Connect アップロード

```bash
./scripts/ios/testflight-upload.sh
```
- Release 構成で generic/iOS を Archive → `config/ios/ExportOptions.plist` で export → ASC アップロード。
- 前提: Xcode ログイン済み、Team `NXFZ5AUX62`、署名 Automatic。

## 3. スクショ / メタデータ登録（必要時）

```bash
./scripts/ios/sync-asc-screenshots.sh   # docs/screenshots → fastlane
./scripts/ios/upload-asc.sh             # deliver で ASC 登録
```

## 4. 審査提出（要・明示確認）

- fastlane `fastlane/Fastfile` のレーン、または ASC 手動。
- **提出はユーザー確認後のみ。** 勝手に submit しない。

## 参考 / 関連

- 手順詳細: `docs/phases/08-app-store-release.md`
- リジェクト・審査指摘対応: Skill `asc-reject`
- メタデータ規約: `docs/guides/app-store-metadata.md`
