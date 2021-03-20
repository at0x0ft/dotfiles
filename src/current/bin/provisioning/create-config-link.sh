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
readonly CURRENT_SETTING_ROOT="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly DOTFILES_LIBRARY_SCRIPTS=$(cd "${CURRENT_SETTING_ROOT}/../lib"; pwd -P)
readonly CONFIG_ROOT="$(cd ${CURRENT_SETTING_ROOT}/../conf; pwd -P)"
readonly CONFIG_LINK=$("${CURRENT_SETTING_ROOT}/lib/get-config-link.sh")

readonly get_config_path="${CONFIG_ROOT}/get-config-path.sh"
readonly make_relative_symlink="${DOTFILES_LIBRARY_SCRIPTS}/make-relative-symlink.sh"

${make_relative_symlink} -a ${CONFIG_LINK} $(${get_config_path} ${1})
