#!/usr/bin/env sh
set -eu

build() {
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
  local readonly SCRIPT_PATH=$(readlinkf "${0}")
  local readonly SCRIPT_ROOT=$(dirname -- "${SCRIPT_PATH}")
  local readonly DOTFILES_ROOT=$(readlinkf "${SCRIPT_ROOT}/..")
  local readonly DOCKERFILE_BASE_NAME='Dockerfile'

  # arguments
  local readonly dockerfile_root=$(readlinkf "${1}")
  if [ ! -d ${dockerfile_root} ]; then
    printf "Not exist: ${dockerfile_root}\n" >&2
    exit 1
  fi

  local readonly tag_version="${2}"

  get_type() {
    if [ "${1}" = '-c' ]; then
      printf 'container'
    else
      printf 'desktop'
    fi
    return 0
  }
  local readonly type="$(get_type "${3}")"

  local readonly tag_name="dotfiles${dockerfile_root##${DOTFILES_ROOT}}/${type}"
  local readonly dockerfile_path="${dockerfile_root}/${DOCKERFILE_BASE_NAME}.${type}"
  local readonly log_path="${dockerfile_root}/build.${type}.log"

  DOCKER_BUILDKIT=1 docker image build \
    -t "${tag_name}:${tag_version}" \
    -f "${dockerfile_path}" \
    --build-arg VERSION="${tag_version}" \
    --build-arg DOTFILES_PATH='.' \
    --build-arg TERM="${TERM}" \
    "${DOTFILES_ROOT}" --progress=plain 2>&1 | tee "${log_path}"

  printf 'Finish building container image!\n'
  printf '[Note]: Container tag = "%s" .\n' "${tag_name}:${tag_version}"
  printf '[Note]: Build log file path = "%s".\n' "${log_path}"

  return 0
}
build "${@}"
