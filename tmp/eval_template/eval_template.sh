#!/usr/bin/env sh
set -eu

hoge='string::hoge'

eval_template() {
  local readonly template_file_path="${1}"
  local readonly evaluated_file_path="${2}"

  local readonly prev_IFS="${IFS}"
  IFS='\n'

  local line
  while read line; do
    eval "printf '%s\n' \"${line}\""
  done < "${template_file_path}" > "${evaluated_file_path}"

  IFS="${prev_IFS}"
  return 0
}

eval_template "${@}"
