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
readonly PROVISIONING_SCRIPTS="${SCRIPT_ROOT}/provisioning"
readonly LIBRARY_SCRIPTS="$(cd ${SCRIPT_ROOT}/../lib; pwd -P)"
readonly CONFIG_ROOT="$(cd ${SCRIPT_ROOT}/../../conf; pwd -P)"

readonly judge_os_type="${LIBRARY_SCRIPTS}/judge-os-type.sh"
readonly get_config_path="${CONFIG_ROOT}/get-config-path.sh"
readonly create_config_link="${PROVISIONING_SCRIPTS}/create-config-link.sh"
# readonly get_preferred_shell_type="${PROVISIONING_SCRIPTS}/get-preferred-shell-type.sh"

echo 'Provisioning for installation...'

echo 'Detecting OS type...'
readonly os_type=$(${judge_os_type})
echo "Detected OS type: ${os_type}"

echo 'Creating link to current system config.'
${create_config_link} $(${get_config_path} ${os_type})

# echo 'Detecting preferred shell type...'
# readonly pref_shell_type=$(${get_preferred_shell_type})
# echo "Detected preferred shell type: ${pref_shell_type}"
# setup_preferred_shell ${shelltype}

# readonly pkmtype=$(read_preferred_shell ${ostype})
# echo "Detected preferred package manager type: ${pkmtype}"
# echo 'Setup package manager'
# echo 'Setup package manager'
# create_shellrc_link
# create_pkmrc_link

# echo 'Start installing'
# ${INITIALIZE_SCRIPT_PATH}


