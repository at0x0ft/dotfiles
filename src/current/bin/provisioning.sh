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
readonly LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

readonly judge_os_type="${LIBRARY_SCRIPTS}/judge-os-type.sh"
readonly create_config_link="${PROVISIONING_SCRIPTS}/create-config-link.sh"

echo 'Provisioning for deployment...'

echo 'Detecting OS type...'
readonly os_type=$(${judge_os_type})
echo "Detected OS type: ${os_type}"

echo 'Creating link to current system config.'
${create_config_link} ${os_type}

echo 'Finish provisioning.'
