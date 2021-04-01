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
readonly PREFERENCE_PATH="${SCRIPT_ROOT}/preference.json"
readonly JQ_PATH='.shell.name'
readonly JQ_INIT_METHOD_PATH='.shell.with'

if [ "${1}" = '-w' ]; then
    jq -r "${JQ_INIT_METHOD_PATH}" "${PREFERENCE_PATH}"
else
    jq -r "${JQ_PATH}" "${PREFERENCE_PATH}"
fi
