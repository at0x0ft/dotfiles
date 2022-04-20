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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
# only supporting zsh
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
# only supporting zsh
readonly RC_DIRECTIVE="source '${RC_PATH}'"

readonly add_directive_to_zshrc_postload="${CURRENT_ROOT}/available/shell/link/rc/postload/add-directive.sh"

${add_directive_to_zshrc_postload} "${RC_DIRECTIVE}"
