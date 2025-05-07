#!/usr/bin/env bash
set -euo pipefail
export DISPLAY=:0

# VNCパスワード設定
/usr/local/bin/vnc-setup.sh

# 解像度設定（デフォルト値）
DEFAULT_RESOLUTION="1920x1080"
RESOLUTION="${RESOLUTION:-${DEFAULT_RESOLUTION}}"

# VNC起動（パスワード認証付き）
echo "[VNC] Xvnc 起動 (解像度: ${RESOLUTION})"
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

# 解像度変更スクリプト
cat > /home/abc/.config/openbox/autostart << 'AUTOSTART'
#!/bin/bash
# 解像度変更スクリプト
/usr/local/bin/resize-desktop.sh &
AUTOSTART
chmod +x /home/abc/.config/openbox/autostart

# Obsidianを起動
echo "[Obsidian] 起動"
APPIMAGE_EXTRACT_AND_RUN=1 /opt/Obsidian.AppImage --no-sandbox &

# タスクが終了するまで待機
wait