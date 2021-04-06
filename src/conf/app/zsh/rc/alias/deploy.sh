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
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly GENERAL_PATH="${SCRIPT_ROOT}/general.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
readonly GENERAL_DIRECTIVE="source '${GENERAL_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"

if [ ! -f "${EXTERNAL_PATH}" ]; then
    touch "${EXTERNAL_PATH}"
fi

printf '%s\n' "${GENERAL_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${EXTERNAL_DIRECTIVE}" >> "${RC_PATH}"
