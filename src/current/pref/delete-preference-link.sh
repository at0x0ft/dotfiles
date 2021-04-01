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
readonly PREFERENCE_SRC_LINK="${SCRIPT_ROOT}/preference.json"

[ -e ${PREFERENCE_SRC_LINK} ] && rm -f ${PREFERENCE_SRC_LINK}
