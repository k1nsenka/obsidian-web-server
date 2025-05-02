# ──────────────────────────────────────────────────────────
# obsidian-web-server (ARM64)
# Ubuntu 22.04 + TigerVNC + noVNC + Openbox + Obsidian
# ──────────────────────────────────────────────────────────
FROM ubuntu:22.04
LABEL maintainer="k1nsenka <https://github.com/k1nsenka>"

# ---- 1. 基本環境変数 ----
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    OB_VERSION=1.8.10 \
    PUID=501 \
    PGID=20 \
    DISPLAY=:0 \
    VNC_PORT=5900 \
    NOVNC_PORT=8080 \
    WEBROOT=/opt/novnc \
    HOME=/home/abc

# ---- 2. ロケール&必須パッケージ ----
    RUN apt-get update && \
    apt-get install -y --no-install-recommends locales tzdata xfonts-base && \
    locale-gen ja_JP.UTF-8 && \
    apt-get install -y --no-install-recommends \
        tigervnc-standalone-server tigervnc-common tigervnc-tools xauth \
        openbox tint2 xterm xfce4-terminal \
        supervisor curl ca-certificates git \
        python3 python3-websockify unzip \
        fonts-noto-cjk libgtk-3-0 libnss3 libxss1 libasound2 \
        sudo at-spi2-core libgbm1 \
        x11-apps x11-utils x11-xserver-utils \
        zlib1g libfuse2 zlib1g-dev && \  
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- 3. noVNC ----
RUN mkdir -p ${WEBROOT} && \
    curl -sSL https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | \
      tar -xz -C /opt && \
    mv /opt/noVNC-1.4.0/* ${WEBROOT} && \
    ln -s ${WEBROOT}/vnc_lite.html ${WEBROOT}/index.html && \
    rm -rf /opt/noVNC-1.4.0

# ---- 4. Obsidian AppImage ----
    RUN curl -L -o /opt/Obsidian.AppImage \
    "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OB_VERSION}/Obsidian-${OB_VERSION}-arm64.AppImage" && \
    chmod +x /opt/Obsidian.AppImage

# AppImage実行用環境設定
ENV APPIMAGE_EXTRACT_AND_RUN=1

# スクリプト作成
RUN echo '#!/bin/bash\nexport DISPLAY=:0\nexport APPIMAGE_EXTRACT_AND_RUN=1\nexec /opt/Obsidian.AppImage --no-sandbox' > /usr/local/bin/obsidian && \
    chmod +x /usr/local/bin/obsidian

# ---- 5. グループとユーザー作成 ----
    RUN groupadd -g ${PGID} abc 2>/dev/null || true
    RUN useradd -m -u ${PUID} -g ${PGID} -s /bin/bash abc 2>/dev/null || true
    RUN usermod -a -G sudo abc
    
    # sudoersファイル修正
    RUN echo "abc ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/abc && \
        chmod 0440 /etc/sudoers.d/abc
    
    # ディレクトリの作成と権限設定
    RUN mkdir -p /vaults /config /home/abc/.config/obsidian && \
        chown -R abc:${PGID} /vaults /config /home/abc

# ---- 6. ディレクトリ準備 ----
RUN mkdir -p /var/run /var/log /tmp /vaults /config /home/abc/.local/share/obsidian-vnc && \
    mkdir -p /home/abc/.vnc /etc/supervisor/conf.d && \
    chown -R abc:${PGID} /var/run /var/log /tmp /home/abc

# ---- 7. スクリプトコピー（READMEの構造に合わせて修正）----
COPY scripts/vnc-setup.sh /usr/local/bin/vnc-setup.sh
COPY scripts/novnc-auth.sh /usr/local/bin/novnc-auth.sh
RUN chmod +x /usr/local/bin/vnc-setup.sh /usr/local/bin/novnc-auth.sh
COPY scripts/start-desktop.sh /usr/local/bin/start-desktop.sh
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/start-desktop.sh && \
    chown abc:${PGID} /usr/local/bin/start-desktop.sh /etc/supervisor/conf.d/supervisord.conf

USER abc
WORKDIR ${HOME}

EXPOSE ${NOVNC_PORT}
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]