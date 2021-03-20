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

readonly DEPLOYED_SHELL_LINK="${CURRENT_ROOT}/deployed/shell"
if [ ! -L ${DEPLOYED_SHELL_LINK} ]; then
    echo "Error: current system deployed shell link (${DEPLOYED_SHELL_LINK}) not found." >&2
    exit 1
fi

readonly get_rc_path="${DEPLOYED_SHELL_LINK}/get-rc-path.sh"
echo $(${get_rc_path})
