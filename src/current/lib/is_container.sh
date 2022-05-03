#!/usr/bin/env sh
set -eu

is_container() {
  if [ -f '/.dockerenv' ]; then
    return 0
  else
    return 1
  fi
}
is_container
