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

readonly UBUNTU_PATH="${SCRIPT_ROOT}/ubuntu"
readonly DEBIAN_PATH="${SCRIPT_ROOT}/debian"
readonly PENGWIN_PATH="${SCRIPT_ROOT}/pengwin"
readonly ALPINE_PATH="${SCRIPT_ROOT}/alpine"
readonly DARWIN_PATH="${SCRIPT_ROOT}/darwin"

not_exist_or_exit() {
    if [ ! -d ${1} ]; then
        printf "Error: Corresponding config path (${1}) not found.\n" >&2
        exit 1
    fi
}

case ${1} in
    "Ubuntu")
        not_exist_or_exit "${UBUNTU_PATH}"
        printf "${UBUNTU_PATH}"
        ;;
    "Debian"*)
        not_exist_or_exit "${DEBIAN_PATH}"
        printf "${DEBIAN_PATH}"
        ;;
    "Pengwin")
        not_exist_or_exit "${PENGWIN_PATH}"
        printf "${PENGWIN_PATH}"
        ;;
    "Alpine")
        not_exist_or_exit "${ALPINE_PATH}"
        printf "${ALPINE_PATH}"
        ;;
    "Darwin")
        not_exist_or_exit "${DARWIN_PATH}"
        printf "${DARWIN_PATH}"
        ;;
    * )
        printf "Error: Corresponding config path not matched with OS type: \"${1}\".\n" >&2
        exit 1
        ;;
esac
