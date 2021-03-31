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
readonly ZSHRC_PATH="$("${SCRIPT_ROOT}/get-rc-path.sh")"
readonly ENVS_DIRECTIVE="source \"${SCRIPT_ROOT}/envs.zsh\""
readonly KEYBINDS_DIRECTIVE="source \"${SCRIPT_ROOT}/keybinds.zsh\""

readonly backup_original_zshrc="${SCRIPT_ROOT}/backup-original-zshrc.sh"

${backup_original_zshrc}

printf '%s\n' "${ENVS_DIRECTIVE}" >> "${ZSHRC_PATH}"
printf '%s\n' "${KEYBINDS_DIRECTIVE}" >> "${ZSHRC_PATH}"

# later move this script
${SCRIPT_ROOT}/../zinit/initialize.sh
