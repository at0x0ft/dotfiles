#!/usr/bin/env sh
set -e

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
readonly ZSH_PATH="${SCRIPT_ROOT}/../zsh"
readonly ZSHRC_PATH=$("${ZSH_PATH}/get-rc-path.sh")
readonly ZINITRC_TEMPLATE_PATH="${SCRIPT_ROOT}/rc.template.zsh"
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"

cp ${ZINITRC_TEMPLATE_PATH} ${ZINITRC_PATH}

echo "source \"${SCRIPT_ROOT}/plugins.zsh\"" >> ${ZINITRC_PATH}

echo "source \"${ZINITRC_PATH}\"" >> ${ZSHRC_PATH}
