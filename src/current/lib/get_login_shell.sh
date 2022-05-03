#!/usr/bin/env sh
set -eu

get_login_shell() {
  if [ $(uname) = 'Darwin' ]; then
    dscl . -read "/Users/${USER}" UserShell | sed -E 's/^.*: (.*)$/\1/'
  else
    local readonly user_passwd_info=$(grep $(whoami) /etc/passwd)
    printf '%s' "${user_passwd_info##*:}"
  fi
  return 0
}
get_login_shell
