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
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly PRELOAD_PATH="${SCRIPT_ROOT}/preload/rc.zsh"
readonly ENV_PATH="${SCRIPT_ROOT}/env/rc.zsh"
readonly KEYBIND_PATH="${SCRIPT_ROOT}/keybind/rc.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external/rc.zsh"
readonly PRELOAD_DIRECTIVE="source '${PRELOAD_PATH}'"
readonly ENV_DIRECTIVE="source '${ENV_PATH}'"
readonly KEYBIND_DIRECTIVE="source '${KEYBIND_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"
readonly DEPLOY_SCRIPT_NAME='deploy.sh'

readonly backup_original_zshrc="${SCRIPT_ROOT}/backup-original-zshrc.sh"

get_subdir_deploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${DEPLOY_SCRIPT_NAME}" -type f
}

${backup_original_zshrc}

for sub_deploy in $(get_subdir_deploy_scripts); do
    echo "debug: ${sub_deploy}"
    ${sub_deploy}
done

printf '%s\n' "${PRELOAD_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${ENV_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${KEYBIND_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${EXTERNAL_DIRECTIVE}" >> "${RC_PATH}"

ln -snvf "${RC_PATH}" "${ZSHRC_PATH}"
