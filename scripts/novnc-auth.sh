#!/usr/bin/env bash
set -euo pipefail

# noVNC用認証トークンを作成
if [ -n "${PASSWORD:-}" ]; then
    mkdir -p /opt/novnc/app/js
    cat > /opt/novnc/app/js/token.js << EOF
var token = '${PASSWORD}';
EOF
fi