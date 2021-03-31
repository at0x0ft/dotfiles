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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly DOTFILES_SRC_ROOT="$(cd ${CURRENT_ROOT}/..; pwd -P)"
readonly PREFERENCE_SRC_LINK="${CURRENT_ROOT}/preference"
readonly CONFIG_LINK=$("${CURRENT_ROOT}/lib/get-config-link.sh")
readonly PREFERENCE_DEFAULT_DST_LINK="${CONFIG_LINK}/preference.json"

readonly make_relative_symlink="${DOTFILES_SRC_ROOT}/lib/make-relative-symlink.sh"

if [ "${1}" = '' ]; then
    ${make_relative_symlink} "${PREFERENCE_SRC_LINK}" "${PREFERENCE_DEFAULT_DST_LINK}"
elif [ -f "${1}" ]; then
    cp "${1}" "${PREFERENCE_SRC_LINK}"
else
    printf 'Error: Given preference path not found.\n' >&2
    exit 1
fi
