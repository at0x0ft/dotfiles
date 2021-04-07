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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../../.."; pwd -P)
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly FAST_SYNTAX_HIGHLIGHTING_PATH="${SCRIPT_ROOT}/fast-syntax-highlighing.zsh"
readonly P10K_LOAD_PATH="${SCRIPT_ROOT}/p10k-load.zsh"
readonly P10K_PATH="${SCRIPT_ROOT}/p10k.zsh"
readonly P10K_INSTANT_PROMPT_PATH="${SCRIPT_ROOT}/p10k-instant-prompt.zsh"
readonly FAST_SYNTAX_HIGHLIGHTING_DIRECTIVE="source '${FAST_SYNTAX_HIGHLIGHTING_PATH}'"
readonly P10K_LOAD_DIRECTIVE="source '${P10K_LOAD_PATH}'"
readonly P10K_DIRECTIVE="source '${P10K_PATH}'"
readonly P10K_INSTANT_PROMPT_DIRECTIVE="source '${P10K_INSTANT_PROMPT_PATH}'"

readonly delete_directive_to_zshrc_preload="${CURRENT_ROOT}/available/shell/link/rc/preload/delete-directive.sh"
readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

${delete_directive_to_zshrc_preload} "${P10K_INSTANT_PROMPT_DIRECTIVE}"

${delete_line} "${P10K_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${P10K_LOAD_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${FAST_SYNTAX_HIGHLIGHTING_DIRECTIVE}" "${RC_PATH}"
if [ ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
fi
