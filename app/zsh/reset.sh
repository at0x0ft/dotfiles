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

for f in $(find ${SCRIPT_ROOT}/* -maxdepth 1 -type d); do
    ${f}/$(basename ${SCRIPT_PATH})
done

sed -i "/^source \"${SCRIPT_ROOT}\/envs.zsh\"$/d" ${ZSHRC_PATH}
sed -i "/^source \"${SCRIPT_ROOT}\/keybinds.zsh\"$/d" ${ZSHRC_PATH}
[ -f ${ZSHRC_BACKUP_PATH} ] && mv ${ZSHRC_BACKUP_PATH} ${ZSHRC_PATH}
