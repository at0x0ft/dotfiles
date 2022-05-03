#!/usr/bin/env sh
set -eu

get_os_type() {
  local readonly LINUX_SPEC_FILE_PATH='/etc/os-release'
  if [ $(uname) = 'Darwin' ]; then
    uname
  else
    grep -e '^NAME=' "${LINUX_SPEC_FILE_PATH}" | sed -r 's/^NAME="(.*)"$/\1/'
  fi
  return 0
}
get_os_type
