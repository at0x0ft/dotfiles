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
readonly CURRENT_SETTING_PATH="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly CONFIG_LINK="${CURRENT_SETTING_PATH}/conf"
readonly PREFERRED_SHELL_LINK="${CONFIG_LINK}/shell/preferred"

if [ ! -L ${CONFIG_LINK} ]; then
    echo "Error: symlink ${CONFIG_LINK} not found." >&2
    exit 1
fi

echo $(cd "$(dirname ${PREFERRED_SHELL_LINK})/"$(readlink ${PREFERRED_SHELL_LINK}); pwd)
