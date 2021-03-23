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
readonly UNDEPLOY_SCRIPTS="${SCRIPT_ROOT}/undeploy"

readonly enumerate_normal_deployed_apps="${UNDEPLOY_SCRIPTS}/enumerate-normal-deployed-apps.sh"
readonly undeploy_app="${UNDEPLOY_SCRIPTS}/undeploy-app.sh"
readonly undeploy_package_manager="${UNDEPLOY_SCRIPTS}/undeploy-package-manager.sh"
readonly undeploy_shell="${UNDEPLOY_SCRIPTS}/undeploy-shell.sh"

echo 'Undeploying...'

echo 'Undeploying other apps...'
for app in $(${enumerate_normal_deployed_apps}); do
    echo "Deploying $(basename ${app})..."
    ${undeploy_app} ${app}
done

echo 'Undeploying shell...'
${undeploy_shell}

echo 'Undeploying package manager...'
${undeploy_package_manager}

echo 'Undeployment finished!'
