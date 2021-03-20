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
readonly ZSHRC_PATH="$("${SCRIPT_ROOT}/../get-rc-path.sh")"
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly ZINITRC_TEMPLATE_PATH="${SCRIPT_ROOT}/rc.template.zsh"

cp ${ZINITRC_TEMPLATE_PATH} ${ZINITRC_PATH}
echo "source \"${SCRIPT_ROOT}/plugins.zsh\"" >> ${ZINITRC_PATH}

echo "source \"${ZINITRC_PATH}\"" >> ${ZSHRC_PATH}

zsh -i -c 'zinit module build; @zinit-scheduler burst || true'
