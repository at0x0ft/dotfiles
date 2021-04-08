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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/..; pwd -P)"
readonly DOTFILES_SRC_ROOT="$(cd ${CURRENT_ROOT}/..; pwd -P)"
readonly PREFERENCE_SRC_LINK="${SCRIPT_ROOT}/preference.json"
readonly CONFIG_LINK=$("${CURRENT_ROOT}/lib/get-config-link.sh")
readonly PREFERENCE_DEFAULT_DST_LINK="${CONFIG_LINK}/preference.json"
readonly PREFERENCE_CONTAINER_DST_LINK="${CONFIG_LINK}/preference.container.json"

readonly is_container="${CURRENT_ROOT}/lib/is-container.sh"
readonly make_relative_symlink="${DOTFILES_SRC_ROOT}/lib/make-relative-symlink.sh"

get_preference_type() {
    if [ "${1}" = '' ]; then
        printf "debug: is_container = $(${is_container})\n" >&2
        if $(${is_container}); then
            printf 'container'
        else
            printf 'desktop'
        fi
    elif [ "${1}" = '-c' ]; then
        printf 'container'
    elif [ "${1}" = '-d' ]; then
        printf 'desktop'
    elif [ -f "${1}" ]; then
        printf 'given'
    else
        printf 'unknown'
    fi
}

readonly preference_type="$(get_preference_type "${1}")"
if [ "${preference_type}" = 'container' ]; then
    ${make_relative_symlink} "${PREFERENCE_SRC_LINK}" "${PREFERENCE_CONTAINER_DST_LINK}"
elif [ "${preference_type}" = 'desktop' ]; then
    ${make_relative_symlink} "${PREFERENCE_SRC_LINK}" "${PREFERENCE_DEFAULT_DST_LINK}"
elif [ "${preference_type}" = 'given' ]; then
    cp "${1}" "${PREFERENCE_SRC_LINK}"
else
    printf 'Error: Given preference path not found.\n' >&2
    exit 1
fi
