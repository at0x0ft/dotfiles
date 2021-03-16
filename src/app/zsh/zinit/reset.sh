#!/usr/bin/env sh
set -e

readonly EXEC_COMMAND=zsh
if !(type ${EXEC_COMMAND} > /dev/null 2>&1); then
    exit 1
fi

readonly SCRIPT_PATH="$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)"
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly DOTFILES_ROOT="$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)"
readonly ZSHRC_PATH="${HOME}/.zshrc"
readonly ZINIT_PATH="${HOME}/.zinit"
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly ZSH_COMPILED_EXT='.zwc'

for f in $(find ${HOME}/* -maxdepth 1 -type f -name "*${ZSH_COMPILED_EXT}"); do
    rm $f
done
for f in $(find ${DOTFILES_ROOT}/* -type f -name "*${ZSH_COMPILED_EXT}"); do
    rm $f
done
[ -d ${ZINIT_PATH} ] && rm -rf ${ZINIT_PATH}

sed -i "/^source \"${ZINITRC_PATH}\"$/d" ${ZSHRC_PATH}

sed -i "/^source \"${SCRIPT_ROOT}\/plugins.zsh\"$/d" ${ZINITRC_PATH}
[ -f ${ZINITRC_PATH} ] && rm ${ZINITRC_PATH}
