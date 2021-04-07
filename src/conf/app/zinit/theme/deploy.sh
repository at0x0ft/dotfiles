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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../../.."; pwd -P)
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

readonly add_directive_to_zshrc_preload="${CURRENT_ROOT}/available/shell/link/rc/preload/add-directive.sh"

printf "${FAST_SYNTAX_HIGHLIGHTING_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${P10K_LOAD_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${P10K_DIRECTIVE}\n" >> "${RC_PATH}"

${add_directive_to_zshrc_preload} "${P10K_INSTANT_PROMPT_DIRECTIVE}"
