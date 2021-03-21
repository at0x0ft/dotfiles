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
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly DOTFILES_SRC_ROOT="$(cd ${CURRENT_ROOT}/..; pwd -P)"
readonly DEPLOYED_DIR="$(${CURRENT_LIBRARY_SCRIPTS}/get-deployed-directory.sh)"
readonly DEPLOYED_APPS="${DEPLOYED_DIR}/app"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"

readonly is_valid_command="${CURRENT_LIBRARY_SCRIPTS}/is-valid-command.sh"
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make-relative-symlink.sh"
readonly can_deploy_script="can-deploy.sh"
readonly app_deploy_script="deploy.sh"

${1}/${can_deploy_script}

${1}/${app_deploy_script}

readonly link_org_path="${DEPLOYED_APPS}/$(basename ${1})"
${make_relative_symlink} ${link_org_path} ${1}
