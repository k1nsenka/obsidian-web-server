#!/usr/bin/env bash
# TigerVNC + Openbox + Obsidian を起動
set -euo pipefail
export DISPLAY=:0

# ログディレクトリの準備
LOGDIR="$HOME/.local/share/obsidian-vnc"
mkdir -p "$LOGDIR"

# VNC起動
echo "[VNC] Xvnc 起動"
/usr/bin/Xvnc :0 -geometry 1920x1080 -SecurityTypes None -ac -depth 24 &
sleep 2

# Openbox起動
echo "[Desktop] Openbox + tint2 起動"
openbox-session &
tint2 &
sleep 1

# Obsidianを起動
echo "[Obsidian] 起動"
obsidian &

# タスクが終了するまで待機
wait