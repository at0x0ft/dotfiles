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

readonly DESKTOP_UBUNTU_PATH="${SCRIPT_ROOT}/desktop/ubuntu"

not_exist_or_exit() {
    if [ ! -d ${1} ]; then
        echo "Error: Corresponding config path (${1}) not found." >&2
        exit 1
    fi
}

case ${1} in
    "Ubuntu")
        not_exist_or_exit ${DESKTOP_UBUNTU_PATH}
        echo ${DESKTOP_UBUNTU_PATH}
        ;;
    * )
        echo "Error: Corresponding config path not matched with OS type: \"${1}\"." >&2
        exit 1
        ;;
esac
