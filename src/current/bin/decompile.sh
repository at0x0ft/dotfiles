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
readonly DECOMPILE_SCRIPT_NAME='decompile.sh'

get_available_app_decompile_scripts() {
    find "${AVAILABLE_APPS}" -follow -maxdepth 2 -name "${DECOMPILE_SCRIPT_NAME}" -type f
}

printf 'Decompiling if needed.\n'
for app_decompile in $(get_available_app_decompile_scripts); do
    app_name="$(basename $(dirname ${app_decompile}))"
    printf "Decompiling ${app_name}...\n"
    [ "${app_name}" != 'zinit' ] && ${app_decompile}
done

printf 'Decompiling finished!\n'
