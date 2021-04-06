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
readonly DEPLOY_SCRIPT_NAME='deploy.sh'

readonly env_deploy="${SCRIPT_ROOT}/env/${DEPLOY_SCRIPT_NAME}"
readonly profile_deploy="${SCRIPT_ROOT}/profile/${DEPLOY_SCRIPT_NAME}"
readonly rc_deploy="${SCRIPT_ROOT}/rc/${DEPLOY_SCRIPT_NAME}"

${env_deploy}
${profile_deploy}
${rc_deploy}
