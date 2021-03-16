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
readonly RESET_SCRIPT_PATTERN="${DOTFILES_ROOT}/app/*/reset.sh"

for f in $(find ${RESET_SCRIPT_PATTERN} -maxdepth 1 -type f); do
    ${f}
done
