#!/usr/bin/env bash
# GitHub 上の Vault を ./vaults にクローン／更新
set -euo pipefail

if [[ -z "${GIT_REPO_URL:-}" ]]; then
  echo "ERROR: GIT_REPO_URL 環境変数を設定してください" >&2
  exit 1
fi

VAULT_NAME="$(basename "${GIT_REPO_URL%%.git}")"
TARGET_DIR="$(dirname "$0")/../vaults/${VAULT_NAME}"

echo "[setup] Vault = ${TARGET_DIR}"

if [[ -d "${TARGET_DIR}/.git" ]]; then
  echo "[setup] 既存のリポジトリを pull" && git -C "${TARGET_DIR}" pull --ff-only
else
  echo "[setup] Vault を clone" && git clone "${GIT_REPO_URL}" "${TARGET_DIR}"
fi