> [!CAUTION]
> ### このプロジェクトは開発中です。一応動きますが快適ではありません。
> ### This project is under development. It works to some extent, but the experience is not smooth.

> [!NOTE]
> 開発予定：画面の解像度に合わせたウィンドウ設定\
> 開発予定：VNCログイン項目


# obsidian-web-server

Apple Silicon（M1/M2/M3）MacBook を **Obsidian.md** のウェブエディタに変身させる、完全オリジナル構築リポジトリです。

TigerVNC + noVNC + Openbox の軽量デスクトップで Obsidian を起動し、GitHub 上の Vault を **obsidian‑git** プラグインで自動同期します。

## 特徴

- 🌐 ブラウザから Obsidian にアクセス可能
- 🔄 GitHub との自動同期
- 🍎 Apple Silicon (ARM64) 対応
- 🪶 軽量な環境構築（Openbox デスクトップ）
- 🐳 Docker によるコンテナ化

## クイックスタート

### 1. 必要なもの

- Docker Desktop for Mac（Apple Silicon 対応版）
- GitHub アカウント
- Git が設定済みの SSH 鍵（`~/.ssh` に配置）
- GitHubに設置済みのObsidian Vault

### 2. クローン

```bash
git clone https://github.com/k1nsenka/obsidian-web-server.git
cd obsidian-web-server
```

### 3. Vault のセットアップ

```bash
# GitHub リポジトリの URL を設定
export GIT_REPO_URL=git@github.com:yourusername/your-vault.git

# Vault をクローン
./scripts/setup.sh
```

### 4. コンテナの起動

```bash
# ビルドと起動
docker compose up -d --build

# ブラウザで Obsidian にアクセス
open http://localhost:5555/
```

## ディレクトリ構成

```
obsidian-web-server/
├── Dockerfile                  # Apple Silicon 用 Dockerfile
├── docker-compose.yml         # Docker Compose 定義
├── scripts/
│   ├── setup.sh               # GitHub Vault クローン／更新
│   └── start-desktop.sh       # VNC + Obsidian 起動スクリプト
├── supervisor/
│   └── supervisord.conf       # プロセスマネージャ設定
├── vaults/                    # Markdown Vault（ボリュームマウント）
└── config/                    # Obsidian 設定（ボリュームマウント）
```

## カスタマイズ

### パスワードの変更

`.env` ファイルを作成して、Obsidian アクセス用パスワードを変更できます：

```bash
# .env
OBS_PASSWORD=your-secure-password
```

### Obsidian バージョンの変更

`Dockerfile` 内の `OB_VERSION` を編集：

```dockerfile
ENV OB_VERSION=1.8.10
```

## トラブルシューティング

### ログの確認

```bash
# Supervisor のログ
docker logs obsidian-web-server

# VNC デスクトップのログ
docker exec obsidian-web-server tail -f /home/abc/.local/share/obsidian-vnc/stdout.log
```

### 直接 VNC 接続

デバッグ用に VNC に直接接続することも可能です：

- ポート: `localhost:5900`
- パスワード: なし

## トラブルシューティング

### AppImage の起動エラー

Obsidian が起動しない場合、`AppImage の実行権限を確認してください：

```bash
docker exec obsidian-web-server ls -la /opt/Obsidian.AppImage
```

### ネットワークの問題

noVNC に接続できない場合、ポートマッピングを確認：

```bash
docker ps | grep obsidian-web-server
```

## コントリビューション

Issues や Pull Requests を歓迎します！

## ライセンス

MIT License

## 免責事項

本プロジェクトは個人使用を目的としています。商用利用の場合は Obsidian の[ライセンス](https://obsidian.md/pricing)を確認してください。