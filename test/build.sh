#!/usr/bin/env sh
set -e

# Usage: ./delete-line.sh delete_content_line dst_file_path
# ${1} = delete_content_line: content line which you want to delete
# ${2} = dst_file_path: path to file which you want to delete content
# calling example: ./make-relative-symlink.sh 'source "/hoge/fuga"' ../../piyo

readonly SCRIPT_PATH=$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly DOTFILES_ROOT=$(cd "${SCRIPT_ROOT}/.."; pwd -P)
readonly DOCKERFILE_BASE_NAME='Dockerfile'

get_type() {
    if [ "${1}" = '-c' ]; then
        printf 'container'
    else
        printf 'desktop'
    fi
}

readonly dockerfile_root="$(cd $(pwd -P)/${1}; pwd -P)"
if [ ! -d ${dockerfile_root} ]; then
    printf "Not exist: ${dockerfile_root}\n" >&2
    exit 1
fi

readonly tag_version="${2}"
readonly type="$(get_type "${3}")"
readonly tag_name="dotfiles${dockerfile_root##${DOTFILES_ROOT}}/${type}"
readonly dockerfile_path="${dockerfile_root}/${DOCKERFILE_BASE_NAME}.${type}"
readonly log_path="${dockerfile_root}/build.${type}.log"

DOCKER_BUILDKIT=1 docker image build \
    -t "${tag_name}:${tag_version}" \
    -f "${dockerfile_path}" \
    --build-arg VERSION="${tag_version}" \
    --build-arg DOTFILES_PATH=. \
    --build-arg TERM="${TERM}" \
    "${DOTFILES_ROOT}" --progress=plain 2>&1 | tee "${log_path}"

printf "Finish building container image!\n"
printf "[Note]: Container tag = ${tag_name}:${tag_version} .\n"
printf "[Note]: Build log file path = ${log_path} .\n"
