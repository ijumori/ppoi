# AdMob セットアップ — っぽい格言

> P6-D: バナー + 共有後インタースティシャル

## 1. AdMob Console で取得する ID

| ID | 用途 | 形式例 |
|----|------|--------|
| **App ID** | アプリ全体 | `ca-app-pub-XXXX~YYYY` |
| **バナー Unit ID** | ホーム画面下部 | `ca-app-pub-XXXX/YYYY` |
| **インタースティシャル Unit ID** | 共有後 | `ca-app-pub-XXXX/YYYY` |

## 2. AdMobConfig.plist を配置

```bash
cp PPOI/Resources/AdMobConfig.plist.example PPOI/Resources/AdMobConfig.plist
```

3つの ID を実際の値に書き換え。

## 3. Info.plist の App ID 更新

`project.yml` の以下を本番 App ID に変更:

```yaml
INFOPLIST_KEY_GADApplicationIdentifier: ca-app-pub-あなたのAppID~XXXXXXXX
```

変更後:

```bash
xcodegen generate
```

## 4. 広告配置

| 位置 | 種類 | タイミング |
|------|------|------------|
| ホーム画面下部 | バナー | 常時 |
| 共有完了後 | インタースティシャル | 𝕏共有シート完了時 |

## 5. DEBUG 開発時（重要）

**Debug ビルドでは本番広告 ID は使われません。** Google 公式デモ ID が自動適用されます。

- バナー上部に **「TEST AD — クリック禁止」** が表示される
- **本番広告を自分でクリックしない**（アカウント停止リスク）
- 詳細: [admob-policy-compliance.md](./admob-policy-compliance.md)

## 6. トラブルシューティング

| 症状 | 対処 |
|------|------|
| 広告が表示されない | App ID / Unit ID を確認、実機でテスト |
| Invalid Ad Unit | AdMob でアプリ・広告ユニット作成済みか確認 |
| テスト広告のみ | `AdMobConfig.plist` の ID が正しいか確認 |
