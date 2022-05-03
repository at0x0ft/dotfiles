#!/usr/bin/env sh
set -eu

get_rc_path() {
  printf '%s/.zshrc' "${HOME}"
  return 0
}
get_rc_path
