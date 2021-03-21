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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly DOTFILES_SRC_ROOT="$(cd ${CURRENT_ROOT}/..; pwd -P)"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly DEPLOYED_DIR="$(${CURRENT_LIBRARY_SCRIPTS}/get-deployed-directory.sh)"
readonly DEPLOYED_APPS="${DEPLOYED_DIR}/app"
readonly DEPLOYED_SHELL_LINK="${DEPLOYED_DIR}/shell"

readonly deploy_app="${SCRIPT_ROOT}/deploy-app.sh"
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make-relative-symlink.sh"

${deploy_app} ${1}

readonly deployed_app_link="${DEPLOYED_APPS}/$(basename ${1})"
${make_relative_symlink} ${DEPLOYED_SHELL_LINK} ${deployed_app_link}
