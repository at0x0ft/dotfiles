#!/usr/bin/env sh
set -eu

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
readonly LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

${LIBRARY_SCRIPTS}/validate-config-link.sh
readonly CONFIG_LINK=$("${LIBRARY_SCRIPTS}/get-config-link.sh")
readonly AVAILABLE_APP_PATTERN="${CONFIG_LINK}/app"

readonly is_valid_command="${LIBRARY_SCRIPTS}/is-valid-command.sh"
readonly get_deployed_apps="${LIBRARY_SCRIPTS}/get-deployed-apps.sh"

is_deployed() {
    local result=false
    for deployed_app in $(${get_deployed_apps}); do
        if [ "$(basename ${1})" = "$(basename ${deployed_app})" ]; then
            result=true
            break
        fi
    done
    echo ${result}
}

is_valid_app() {
    echo $(${is_valid_command} $(basename ${1}))
}

for app in $(find ${AVAILABLE_APP_PATTERN} -maxdepth 1 -type l); do
    if [ "$(is_valid_app ${app})" = "true" -a "$(is_deployed ${app})" = "false" ]; then
        echo ${app}
    fi
done
