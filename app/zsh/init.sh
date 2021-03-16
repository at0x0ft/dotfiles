#!/usr/bin/env sh
set -e

readonly EXEC_COMMAND=zsh
if !(type ${EXEC_COMMAND} > /dev/null 2>&1); then
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
readonly DOTFILES_ROOT=$(cd "${SCRIPT_ROOT}/../.."; pwd -P)
readonly ZSHRC_PATH="${HOME}/.zshrc"
readonly ZSHRC_BACKUP_PATH="${DOTFILES_ROOT}/bak/zshrc.bak"

[ -f ${ZSHRC_PATH} -a ! -f ${ZSHRC_BACKUP_PATH} ] && mv ${ZSHRC_PATH} ${ZSHRC_BACKUP_PATH}
echo "source \"${SCRIPT_ROOT}/envs.zsh\"" >> ${ZSHRC_PATH}
echo "source \"${SCRIPT_ROOT}/keybinds.zsh\"" >> ${ZSHRC_PATH}

for f in $(find ${SCRIPT_ROOT}/* -maxdepth 1 -type d); do
    ${f}/$(dirname ${SCRIPT_PATH})
done
