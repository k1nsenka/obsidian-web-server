#!/usr/bin/env bash
set -euo pipefail

# VNCパスワード設定
if [ -n "${PASSWORD:-}" ]; then
    # VNCディレクトリとパスワードファイルを作成
    mkdir -p /home/abc/.vnc
    # パスワードを設定
    echo "${PASSWORD}" | /usr/bin/vncpasswd -f > /home/abc/.vnc/passwd
    chmod 600 /home/abc/.vnc/passwd
    echo "[VNC] パスワードを設定しました"
else
    echo "[VNC] パスワードなしで実行します"
fi