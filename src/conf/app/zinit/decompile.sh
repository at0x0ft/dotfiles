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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly COMPILEDRC_PATH="${SCRIPT_ROOT}/compiled-module-rc.zsh"
readonly COMPILEDRC_DIRECTIVE="source '${COMPILEDRC_PATH}'"
readonly ZSH_COMPILED_EXT='.zwc'

readonly delete_directive_from_zshrc_preload="${CURRENT_ROOT}/available/shell/link/rc/preload/delete-directive.sh"

${delete_directive_from_zshrc_preload} "${COMPILEDRC_DIRECTIVE}"

get_compiled_files() {
    find ${HOME} -name "*${ZSH_COMPILED_EXT}*" -type f
}

for compiled_file in $(get_compiled_files); do
    rm -f ${compiled_file}
done
