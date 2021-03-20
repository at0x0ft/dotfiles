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
readonly get_preferred_shell_link="${PROVISIONING_SCRIPTS}/get-preferred-shell-link.sh"
readonly get_preferred_package_manager_link="${PROVISIONING_SCRIPTS}/get-preferred-package-manager-link.sh"

readonly deploy="${SCRIPT_ROOT}/deploy.sh"

echo 'Provisioning for deployment...'

echo 'Detecting OS type...'
readonly os_type=$(${judge_os_type})
echo "Detected OS type: ${os_type}"

echo 'Creating link to current system config.'
${create_config_link} ${os_type}

echo 'Detecting preferred shell type...'
readonly pref_shell_reallink=$(${get_preferred_shell_link})
echo "Detected preferred shell type: $(basename ${pref_shell_reallink})"
echo 'Deploying...'
# ${deploy} ${pref_shell_reallink}

echo 'Detecting preferred package manager type...'
readonly pref_package_manager_reallink=$(${get_preferred_package_manager_link})
echo "Detected preferred package manager type: $(basename ${pref_package_manager_reallink})"
echo 'Deploying...'
# ${deploy} ${pref_package_manager_reallink}

echo 'Start deploying other apps'
# ${INITIALIZE_SCRIPT_PATH}


