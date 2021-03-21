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
readonly DOTFILES_SRC_ROOT="$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)"
readonly ZSHRC_PATH="$("${SCRIPT_ROOT}/get-rc-path.sh")"
readonly SUBAPPS_PATTERN="${SCRIPT_ROOT}/*"

readonly backup_original_zshrc="${SCRIPT_ROOT}/backup-original-zshrc.sh"

${backup_original_zshrc}

echo "source \"${SCRIPT_ROOT}/envs.zsh\"" >> ${ZSHRC_PATH}
echo "source \"${SCRIPT_ROOT}/keybinds.zsh\"" >> ${ZSHRC_PATH}

for subapp in $(find ${SUBAPPS_PATTERN} -maxdepth 1 -type d); do
    ${subapp}/$(basename ${SCRIPT_PATH})
done
