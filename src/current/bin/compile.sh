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
readonly AVAILABLE_APPS="${CURRENT_ROOT}/available/app"
readonly COMPILE_SCRIPT_NAME='compile.sh'

get_available_app_compile_scripts() {
    find "${AVAILABLE_APPS}" -follow -maxdepth 2 -name "${COMPILE_SCRIPT_NAME}" -type f
}

printf 'Compiling if needed.\n'
for app_compile in $(get_available_app_compile_scripts); do
    app_name="$(basename $(dirname ${app_compile}))"
    printf "Compiling ${app_name}...\n"
    ${app_compile}
done

printf 'Compiling finished!\n'
