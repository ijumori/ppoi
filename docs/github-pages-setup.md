# GitHub Pages 公開手順 — プライバシーポリシー

> リポジトリ: https://github.com/ijumori/ppoi

## 公開される URL（予定）

| ページ | URL |
|--------|-----|
| プライバシーポリシー | `https://ijumori.github.io/ppoi/legal/privacy-policy.html` |
| サポート（Issues） | `https://github.com/ijumori/ppoi/issues` |

---

## 1. ローカルから GitHub へ初回プッシュ

プロジェクトフォルダで:

```bash
cd "/Users/takahironishii/マイドライブ（ijumorimori@gmail.com）/04.Dev/PPOI"

git init
git remote add origin https://github.com/ijumori/ppoi.git

# 秘密情報はコミットしない（.gitignore 済み）
git add .
git commit -m "Initial commit: っぽい格言 MVP"
git branch -M main
git push -u origin main
```

> `GoogleService-Info.plist` と `AdMobConfig.plist` は `.gitignore` 対象です。

---

## 2. GitHub Pages を有効化

1. https://github.com/ijumori/ppoi → **Settings** → **Pages**
2. **Source**: Deploy from a branch
3. **Branch**: `main` / フォルダ **`/docs`**
4. **Save**
5. 1〜3分後に公開: `https://ijumori.github.io/ppoi/...`

---

## 3. 動作確認

ブラウザで開く:

```
https://ijumori.github.io/ppoi/legal/privacy-policy.html
```

表示されれば App Store Connect の「プライバシーポリシー URL」に貼れる。

---

## 4. App Store Connect に入力

| 項目 | URL |
|------|-----|
| プライバシーポリシー | `https://ijumori.github.io/ppoi/legal/privacy-policy.html` |
| サポート URL | `https://github.com/ijumori/ppoi/issues` |

---

## トラブルシューティング

| 症状 | 対処 |
|------|------|
| 404 | Pages 設定で `/docs` になっているか確認 |
| ビルド失敗 | `docs/.nojekyll` があるか確認 |
| 古い内容 | ブラウザキャッシュ削除 / 数分待つ |
