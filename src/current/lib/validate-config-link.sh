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

readonly config_link=$("${SCRIPT_ROOT}/get-config-link.sh")
if [ ! -L ${config_link} ]; then
    echo "Error: current system config link (${CONFIG_LINK}) not found." >&2
    exit 1
fi
