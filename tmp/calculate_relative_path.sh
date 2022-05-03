#!/usr/bin/env sh
set -eu

# ref: https://github.com/ko1nksm/readlinkf/blob/master/readlinkf.sh
readlinkf() {
  [ "${1:-}" ] || return 1
  max_symlinks=40
  CDPATH='' # to avoid changing to an unexpected directory

  target=$1
  [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
  [ -d "${target:-/}" ] && target="$target/"

  cd -P . 2>/dev/null || return 1
  while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
    if [ ! "$target" = "${target%/*}" ]; then
      case $target in
        /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
        *) cd -P "./${target%/*}" 2>/dev/null || break ;;
      esac
      target=${target##*/}
    fi

    if [ ! -L "$target" ]; then
      target="${PWD%/}${target:+/}${target}"
      printf '%s\n' "${target:-/}"
      return 0
    fi

    # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
    #   <file mode>, <number of links>, <owner name>, <group name>,
    #   <size>, <date and time>, <pathname of link>, <contents of link>
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
    link=$(ls -dl -- "$target" 2>/dev/null) || break
    target=${link#*" $target -> "}
  done
  return 1
}

calculate_relative_path() {
  local readonly origin=$(readlinkf "${1}")
  local readonly destination=$(readlinkf "${2}")
  # printf "debug = %s -> %s\n" "${1}" "${origin}" >&2

  if [ ! -d "${origin}" ]; then
    printf '[Error]: 1st argument path must be the path to directory.\n' >&2
    printf '[Error]: Exit.\n' >&2
    exit 1
  fi

  get_common_ancestor_path() {
    local path1="${1#/}"
    local path2="${2#/}"
      # printf "debug = %s -> %s\n" "${1}" "${path1}" >&2
    local result=''
    while true; do
      local dirname1="${path1%%/*}"
      path1="${path1#*/}"
      local dirname2="${path2%%/*}"
      path2="${path2#*/}"
      if [ "${dirname1}" != "${dirname2}" ]; then
        printf "%s" "${result}"
        return 0
      fi
      result="${result}/${dirname1}"
      # printf "result = %s\n" "${result}" >&2
    done
    return 1
  }

  local readonly common_ancestor_path=$(get_common_ancestor_path "${origin}" "${destination}")
  printf "debug = ${common_ancestor_path}\n" >&2

  get_relative_path_from_common() {
    local readonly path="${1}"
    local readonly common_path="${2}"
    local readonly rest_path=${path##"${common_path}"}
    printf '%s' "${rest_path#?}"
    return 0
  }
  local readonly common_to_origin_relative_path=$(get_relative_path_from_common "${origin}" "${common_ancestor_path}")
  local readonly common_to_destination_relative_path=$(get_relative_path_from_common "${destination}" "${common_ancestor_path}")
  printf "debug = ${common_to_origin_relative_path}\n" >&2
  printf "debug = ${common_to_destination_relative_path}\n" >&2

  calculate_relative_ancestor_path() {
    local path="${1}"
    local result=''
    if [ "${path}" = '' ]; then
      printf '%s' "${result}"
      return 0
    fi
    result='..'
    while [ "${path}" != "${path%/*}" ]; do
      result="${result}/.."
      path="${path%/*}"
    done
    printf '%s' "${result}"
    return 0
  }
  local readonly relative_ancestor_path=$(calculate_relative_ancestor_path "${common_to_origin_relative_path}")
  printf "debug = ${relative_ancestor_path}\n" >&2

  connect_origin_to_destination_relative_path() {
    local readonly relative_ancestor_path="${1}"
    local readonly relative_descendant_path="${2}"
    if [ "${relative_ancestor_path}" = "" ]; then
      printf '%s' "${relative_descendant_path}"
      return 0
    fi
    printf '%s/%s' "${relative_ancestor_path}" "${relative_descendant_path}"
    return 0
  }
  connect_origin_to_destination_relative_path "${relative_ancestor_path}" "${common_to_destination_relative_path}"

  return 0
}
calculate_relative_path "${@}"
