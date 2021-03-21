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

if [ -f ${BACKUP_DST_PATH} ]; then
    mv ${BACKUP_DST_PATH} ${ZSHRC_PATH}
fi
