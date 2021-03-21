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
readonly SCRIPT_NAME="$(basename ${SCRIPT_PATH})"
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/..; pwd -P)"
readonly LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly DEPLOYED_DIR="$(${LIBRARY_SCRIPTS}/get-deployed-directory.sh)"
readonly DEPLOYED_APPS="${DEPLOYED_DIR}/app"

echo 'Compiling if needed'
for app_compile_script in $(find ${DEPLOYED_APPS} -follow -name ${SCRIPT_NAME} -type f); do
    echo "Compiling $(basename $(dirname ${app_compile_script}))..."
    ${app_compile_script}
done

echo 'Compiling finished!'
