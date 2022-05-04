#!/bin/sh
set -eu

args() {
  args2() {
    printf 'arg = %s\n' "${@}"
    return 0
  }
  # printf 'arg = %s\n' "${@}"
  args2 "${@}"
  return 0
}
args "${@}"
