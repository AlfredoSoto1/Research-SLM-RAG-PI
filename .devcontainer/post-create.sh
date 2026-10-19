#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required to set permissions on the frontend volumes." >&2
    exit 1
  fi
  exec sudo -- bash "$0" "$@"
fi

frontend_dir="/workspace/frontend"
mkdir -p "${frontend_dir}/node_modules" "${frontend_dir}/.next"

owner="${SUDO_USER:-$(id -un)}"
group="$(id -gn "${owner}")"
chown -R "${owner}:${group}" \
  "${frontend_dir}/node_modules" \
  "${frontend_dir}/.next"
chmod -R u+rwX,g+rwX,o-rwx \
  "${frontend_dir}/node_modules" \
  "${frontend_dir}/.next"
