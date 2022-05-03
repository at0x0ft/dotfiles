#!/usr/bin/env sh
set -eu

test1() {
  printf "1 = '${1}', 2 = '${2}', 3 = '${3}'\n"
  return 0
}

main() {
  printf "1 = '${1}', 2 = '${2}', 3 = '${3}'\n"
  test1 ${@}
  test1 "${@}"
  return 0
}
main "hoge 'fuga'" piyo zoi
