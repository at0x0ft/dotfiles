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
readonly UNDEPLOY_SCRIPT_NAME='undeploy.sh'

readonly env_undeploy="${SCRIPT_ROOT}/env/${UNDEPLOY_SCRIPT_NAME}"
readonly profile_undeploy="${SCRIPT_ROOT}/profile/${UNDEPLOY_SCRIPT_NAME}"
readonly rc_undeploy="${SCRIPT_ROOT}/rc/${UNDEPLOY_SCRIPT_NAME}"

${rc_undeploy}
${profile_undeploy}
${env_undeploy}
