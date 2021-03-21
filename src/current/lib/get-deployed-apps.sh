#!/usr/bin/env sh
set -eu

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
readonly DEPLOYED_DIR="$(${SCRIPT_ROOT}/get-deployed-directory.sh)"
readonly DEPLOYED_APPS="${DEPLOYED_DIR}/app/*"

find ${DEPLOYED_APPS} -maxdepth 1 -type l
