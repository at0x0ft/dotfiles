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
readonly CURRENT_SETTING_ROOT="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_SETTING_ROOT}/lib"
${CURRENT_LIBRARY_SCRIPTS}/validate-config-link.sh
readonly CONFIG_LINK=$("${CURRENT_LIBRARY_SCRIPTS}/get-config-link.sh")
readonly PREFERRED_PACKAGE_MANAGER_LINK="${CONFIG_LINK}/package-manager/preferred"

echo $(cd "$(dirname ${PREFERRED_PACKAGE_MANAGER_LINK})/"$(readlink ${PREFERRED_PACKAGE_MANAGER_LINK}); pwd)
