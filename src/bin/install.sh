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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/.."; pwd -P)
readonly CURRENT_SCRIPTS="${DOTFILES_SRC_ROOT}/current/bin"

readonly provisioning="${CURRENT_SCRIPTS}/provisioning.sh"
readonly deploy="${CURRENT_SCRIPTS}/deploy.sh"
readonly compile="${CURRENT_SCRIPTS}/compile.sh"

${provisioning}
${deploy}
${compile}

printf 'Now, you should restart shell!\n'
printf 'ex: exec [your preferred shell] -l\n'
