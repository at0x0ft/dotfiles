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

readonly deployed_shell_link="$(${SCRIPT_ROOT}/get-deployed-directory.sh)/shell"
if [ ! -L ${deployed_shell_link} ]; then
    echo "Error: current system deployed shell link (${deployed_shell_link}) not found." >&2
    exit 1
fi

readonly get_rc_path="${deployed_shell_link}/get-rc-path.sh"
echo $(${get_rc_path})
