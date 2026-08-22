# daily-podcast

このリポジトリは、AIが生成した短編小説を毎日自動で公開するプロジェクトです。生成されたエピソードは、ポッドキャスト（`/docs/rss.xml` 経由、GitHub Pagesで配信）とプレーンテキストの両方の形式で公開されます。

## 構成

- `/docs/index.html` — ポッドキャストのランディングページ
- `/docs/rss.xml` — ポッドキャスト用RSSフィード
- `/docs/episodes/` — 各エピソードの音声・テキストファイルを格納するディレクトリ

## GitHub Pagesの設定

このサイトを公開するには、リポジトリの設定で以下を一度だけ手動で行う必要があります。

1. `Settings` > `Pages` を開く
2. `Source` を `Deploy from a branch` に設定
3. `Branch` を `main`、フォルダを `/docs` に設定して保存
