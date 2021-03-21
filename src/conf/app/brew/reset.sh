#!/usr/bin/env sh
set -e

readonly EXEC_COMMAND=brew
if !(type ${EXEC_COMMAND} > /dev/null 2>&1); then
    exit 1
fi
readonly SHELLRC_LINK="${DOTFILES_SRC_ROOT}/shellrc"
if [ -L ${SHELLRC_LINK} ]; then
    echo '[Error (reset on brew)]: Not found shellrc link in dotfiles' >&2
    exit 1
fi

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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../.."; pwd -P)
readonly UTILS_PATH="${DOTFILES_SRC_ROOT}/util"
. "${UTILS_PATH}/command-check.sh"
readonly APP_UNREGISTER_PATH="${DOTFILES_SRC_ROOT}/etc/current/app/unregister.sh"

sed -i "/^\. \"${SCRIPT_ROOT}\/rc.sh\"$/d" ${SHELLRC_LINK}

${APP_UNREGISTER_PATH}
