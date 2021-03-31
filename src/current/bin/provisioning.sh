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
readonly PROVISIONING_SCRIPTS="${SCRIPT_ROOT}/provisioning"

readonly get_os_type="${CURRENT_ROOT}/lib/get-os-type.sh"
readonly create_config_link="${PROVISIONING_SCRIPTS}/create-config-link.sh"
readonly create_preference_link="${PROVISIONING_SCRIPTS}/create-preference-link.sh"

printf 'Provisioning for deployment...\n'

printf 'Detecting OS type...\n'
readonly os_type=$(${get_os_type})
printf "Detected OS type: ${os_type}\n"

printf 'Creating link to current system config.\n'
${create_config_link} ${os_type}

printf 'Creating link to preference.\n'
${create_preference_link} "${1}"

# install requirements packages (ex: jq)

printf 'Provisioning finished!\n'
