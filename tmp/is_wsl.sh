#!/usr/bin/env sh
set -eu

is_wsl() {
  local readonly WSL_FEATURE_PATH='/proc/sys/fs/binfmt_misc/WSLInterop'

  if [ -f ${WSL_FEATURE_PATH} ]; then
    return 0
  else
    return 1
  fi
}
is_wsl
