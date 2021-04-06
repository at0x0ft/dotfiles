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
readonly ALIAS_PATH="${SCRIPT_ROOT}/alias.sh"
readonly ALIAS_DIRECTIVE=". '${ALIAS_PATH}'"

readonly add_directive_to_zshrc_alias="${CURRENT_ROOT}/available/shell/link/rc/alias/add-directive.sh"

${add_directive_to_zshrc_alias} "${ALIAS_DIRECTIVE}"
