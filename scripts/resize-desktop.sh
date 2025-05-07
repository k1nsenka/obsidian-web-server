#!/usr/bin/env bash
# 接続元デバイスの解像度を検出してVNCディスプレイサイズを調整

set -euo pipefail

LOG_FILE="/home/abc/.local/share/obsidian-vnc/resize.log"
mkdir -p "$(dirname "$LOG_FILE")"

# NoVNCログから接続クライントの解像度を検出
get_client_resolution() {
    local res=$(xrandr | grep -E '\*' | awk '{print $1}' | head -n 1)
    echo "${res:-1920x1080}"
}

# 解像度を設定
set_resolution() {
    local desired_resolution="$1"
    
    echo "[$(date)] 解像度を変更中: ${desired_resolution}" >> "$LOG_FILE"
    
    # Xディスプレイのサイズを変更
    if xrandr | grep -q "${desired_resolution}"; then
        xrandr -s "${desired_resolution}"
        echo "[$(date)] 解像度の変更に成功しました: ${desired_resolution}" >> "$LOG_FILE"
    else
        # 指定された解像度が利用できない場合は、最も近いものを使用
        xrandr -s $(xrandr | grep -E '[0-9]+x[0-9]+' | awk '{print $1}' | sort -n | head -n 1)
        echo "[$(date)] 指定された解像度が見つかりません。デフォルトを使用します" >> "$LOG_FILE"
    fi
}

# Obsidianウィンドウの再配置
resize_obsidian_window() {
    sleep 3
    
    # xpropでObsidianのウィンドウIDを取得
    WINDOW_ID=$(xdotool search --name "Obsidian" | head -n 1)
    
    if [ -n "$WINDOW_ID" ]; then
        # ディスプレイサイズの80%に設定
        local screen_width=$(xrandr | grep primary | grep -o '[0-9]\+x[0-9]\+' | cut -d'x' -f1)
        local screen_height=$(xrandr | grep primary | grep -o '[0-9]\+x[0-9]\+' | cut -d'x' -f2)
        
        local window_width=$((screen_width * 80 / 100))
        local window_height=$((screen_height * 80 / 100))
        local pos_x=$((screen_width / 10))
        local pos_y=$((screen_height / 10))
        
        xdotool windowmove $WINDOW_ID $pos_x $pos_y
        xdotool windowsize $WINDOW_ID $window_width $window_height
        
        echo "[$(date)] Obsidianウィンドウをリサイズしました: ${window_width}x${window_height}" >> "$LOG_FILE"
    fi
}

# 初期設定と監視ループ
initial_resolution=$(get_client_resolution)
set_resolution "$initial_resolution"
resize_obsidian_window

# NoVNC接続の変化を監視（簡易的な実装）
while true; do
    sleep 10
    current_resolution=$(get_client_resolution)
    if [ "$current_resolution" != "$initial_resolution" ]; then
        echo "[$(date)] 解像度の変化を検出: ${initial_resolution} -> ${current_resolution}" >> "$LOG_FILE"
        set_resolution "$current_resolution"
        resize_obsidian_window
        initial_resolution="$current_resolution"
    fi
done