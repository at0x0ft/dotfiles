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
readonly ZSHRC_PATH="${HOME}/.zshrc"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly PRELOAD_PATH="${SCRIPT_ROOT}/preload/rc.zsh"
readonly ENVAR_PATH="${SCRIPT_ROOT}/envar/rc.zsh"
readonly KEYBIND_PATH="${SCRIPT_ROOT}/keybind/rc.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external/rc.zsh"
readonly PRELOAD_DIRECTIVE="source '${PRELOAD_PATH}'"
readonly ENVAR_DIRECTIVE="source '${ENVAR_PATH}'"
readonly KEYBIND_DIRECTIVE="source '${KEYBIND_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"
readonly DEPLOY_SCRIPT_NAME='deploy.sh'

get_subdir_deploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${DEPLOY_SCRIPT_NAME}" -type f
}

for sub_deploy in $(get_subdir_deploy_scripts); do
    ${sub_deploy}
done

printf "${PRELOAD_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${ENVAR_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${KEYBIND_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${EXTERNAL_DIRECTIVE}\n" >> "${RC_PATH}"

ln -snvf "${RC_PATH}" "${ZSHRC_PATH}"
