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

readonly restore_original_zshrc="${SCRIPT_ROOT}/restore-original-zshrc.sh"

${restore_original_zshrc}

delete_directive_from_rcfile() {
    local directive_lineno=$(grep -n "${1}" "${ZSHRC_PATH}" | cut -d ':' -f 1)
    sed -i "${directive_lineno}d" "${ZSHRC_PATH}" && [ ! -s "${ZSHRC_PATH}" ] && rm -f "${ZSHRC_PATH}"
    return 0
}

delete_directive_from_rcfile "${ENVS_DIRECTIVE}"
delete_directive_from_rcfile "${KEYBINDS_DIRECTIVE}"
