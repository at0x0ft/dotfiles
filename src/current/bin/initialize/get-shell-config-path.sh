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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

${LIBRARY_SCRIPTS}/validate-config-link.sh
readonly CONFIG_LINK=$("${LIBRARY_SCRIPTS}/get-config-link.sh")
readonly SHELLS_PATH="${CONFIG_LINK}/shell"

# consider resolving default shell name

if [ -L "${SHELLS_PATH}/${1}" ]; then
    printf "${SHELLS_PATH}/${1}"
else
    printf "Error: Cannot avaliable ${1}.\n" >&2
    exit 1
fi
