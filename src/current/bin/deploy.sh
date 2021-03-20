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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/..; pwd -P)"
readonly DOTFILES_SRC_ROOT="$(cd ${CURRENT_ROOT}/..; pwd -P)"
readonly DEPLOYED_DIR="${CURRENT_ROOT}/deployed"
readonly DEPLOYED_APPS="${DEPLOYED_DIR}/app"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
${CURRENT_LIBRARY_SCRIPTS}/validate-config-link.sh
readonly CONFIG_LINK=$("${CURRENT_LIBRARY_SCRIPTS}/get-config-link.sh")

readonly is_valid_command="${CURRENT_LIBRARY_SCRIPTS}/is-valid-command.sh"
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make-relative-symlink.sh"
readonly app_deploy_script="deploy.sh"

readonly exec_command=$(basename ${1})
echo ${exec_command}
if ! $(${is_valid_command} ${exec_command}); then
    echo "[Error] Given app command (${exec_command}) is not executable." >&2
    exit 1
fi

echo ${1}
echo $(basename $(dirname ${1}))

${1}/${app_deploy_script}

readonly link_org_path="${DEPLOYED_APPS}/${exec_command}"
${make_relative_symlink} ${link_org_path} ${1}

readonly deploy_type="$(basename $(dirname ${1}))"
case ${deploy_type} in
    'shell' )
        ${make_relative_symlink} "${DEPLOYED_DIR}/shell" ${link_org_path}
        ;;
    'package-manager' )
        ${make_relative_symlink} "${DEPLOYED_DIR}/package-manager" ${link_org_path}
        ;;
esac
