#!/usr/bin/env sh
set -eu

delete_line() {
  local readonly delete_content_line="${1}"
  local readonly destination_file_path="${2}"

  local readonly search_result=$(grep -n "${delete_content_line}" "${destination_file_path}")
  [ "${search_result}" = '' ] && return 1

  local readonly destination_file_name=$(basename -- "${destination_file_path}")
  local readonly deleted_temporary_file_path="/tmp/${destination_file_name}"
  local readonly directive_lineno="${search_result%%:*}"
  sed "${directive_lineno}d" "${destination_file_path}" > "${deleted_temporary_file_path}"
  mv -f "${deleted_temporary_file_path}" "${destination_file_path}"
  return 0
}
delete_line "${@}"
