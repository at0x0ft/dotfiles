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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../.."; pwd -P)
readonly ZSHRC_PATH=$("${SCRIPT_ROOT}/get-rc-path.sh")
readonly BACKUP_DST_PATH="${DOTFILES_SRC_ROOT}/current/bak/zshrc"

if [ -f ${ZSHRC_PATH} -a ! -f ${ZSHRC_BACKUP_PATH} ]; then
    mv ${ZSHRC_PATH} ${BACKUP_DST_PATH}
fi
