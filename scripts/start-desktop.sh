#!/usr/bin/env bash
set -euo pipefail
export DISPLAY=:0

# VNCパスワード設定
/usr/local/bin/vnc-setup.sh

# 解像度の環境変数
RESOLUTION="${RESOLUTION:-1920x1080}"

# VNC起動（パスワード認証付き）
echo "[VNC] Xvnc 起動"
if [ -f /home/abc/.vnc/passwd ]; then
    /usr/bin/Xvnc :0 -geometry "${RESOLUTION}" -PasswordFile /home/abc/.vnc/passwd -ac -depth 24 -SecurityTypes VncAuth &
else
    /usr/bin/Xvnc :0 -geometry "${RESOLUTION}" -SecurityTypes None -ac -depth 24 &
fi

sleep 2

# Openbox起動
echo "[Desktop] Openbox + tint2 起動"
openbox-session &
tint2 &
sleep 1

# Obsidianを起動
echo "[Obsidian] 起動"
APPIMAGE_EXTRACT_AND_RUN=1 /opt/Obsidian.AppImage --no-sandbox &

# タスクが終了するまで待機
wait