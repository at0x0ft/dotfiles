#!/usr/bin/env sh
set -eu

debug_print_before() {
  printf '\n[DEBUG] before\n'
  cat "${1}"
  printf '\n[DEBUG] END\n'
  return 0
}

debug_print_after() {
  printf '\n[DEBUG] after\n'
  cat "${1}"
  printf '\n[DEBUG] END\n'
  return 0
}

delete_line() {
  local readonly delete_content_line="${1}"
  local readonly destination_file_path="${2}"

  debug_print_before "${destination_file_path}" # 4debug
  local readonly search_result=$(grep -n "${delete_content_line}" "${destination_file_path}")
  [ "${search_result}" = '' ] && return 1

  local readonly destination_file_name=$(basename -- "${destination_file_path}")
  local readonly deleted_temporary_file_path="/tmp/${destination_file_name}"
  local readonly directive_lineno="${search_result%%:*}"
  sed "${directive_lineno}d" "${destination_file_path}" > "${deleted_temporary_file_path}"
  mv -f "${deleted_temporary_file_path}" "${destination_file_path}"
  debug_print_after "${destination_file_path}"  # 4debug
  return 0
}
delete_line "${@}"
