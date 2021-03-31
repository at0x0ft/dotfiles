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
readonly SETTING_DIRECTIVE=". \"${SCRIPT_ROOT}\""

readonly shellprofile_path=$("${SCRIPT_ROOT}/get-shellprofile-path.sh")
readonly directive_lineno=$(grep -n "${SETTING_DIRECTIVE}" "${shellprofile_path}" | cut -d ':' -f1)
sed -i "${directive_lineno}d" "${shellprofile_path}" && [ ! -s "${shellprofile_path}" ] && rm -f "${shellprofile_path}"

return 0
