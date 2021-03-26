#!/usr/bin/env sh
set -e

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

readonly GIVEN_PATH="$(pwd -P)/${1}"
if [ ! -f ${GIVEN_PATH} ]; then
    echo "Not exist: ${GIVEN_PATH}" >&2
    exit 1
fi

readonly DOCKERFILE_PATH="$(cd $(dirname ${GIVEN_PATH}); pwd -P)/$(basename ${1})"
readonly DOCKERFILE_ROOT=$(dirname ${DOCKERFILE_PATH})
readonly TAG_NAME="dotfiles${DOCKERFILE_ROOT##${DOTFILES_ROOT}}"
readonly TAG_VERSION=${2}
readonly LOG_PATH="${SCRIPT_ROOT}/build.log"

DOCKER_BUILDKIT=1 docker image build \
    -t "${TAG_NAME}:${TAG_VERSION}" \
    -f ${DOCKERFILE_PATH} \
    --build-arg VERSION=${TAG_VERSION} \
    --build-arg DOTFILES_PATH=. \
    --build-arg TERM="${TERM}" \
    ${DOTFILES_ROOT} --progress=plain 2>&1 | tee ${LOG_PATH}
