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
readonly JQ_QUERY='.plugin_manager | [ .name, .with ] | join("/")'

jq -r "${JQ_QUERY}" "${PREFERENCE_PATH}"
