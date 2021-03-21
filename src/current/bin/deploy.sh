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
readonly DEPLOY_SCRIPTS="${SCRIPT_ROOT}/deploy"

readonly get_preferred_shell_link="${DEPLOY_SCRIPTS}/get-preferred-shell-link.sh"
readonly get_preferred_package_manager_link="${DEPLOY_SCRIPTS}/get-preferred-package-manager-link.sh"
readonly deploy_shell="${DEPLOY_SCRIPTS}/deploy-shell.sh"
readonly deploy_package_manager="${DEPLOY_SCRIPTS}/deploy-package-manager.sh"
readonly enumaerate_not_deployed_valid_apps="${DEPLOY_SCRIPTS}/enumerate-not-deployed-valid-apps.sh"
readonly deploy_app="${DEPLOY_SCRIPTS}/deploy-app.sh"

echo 'Deploying...'

echo 'Detecting preferred shell type...'
readonly pref_shell_reallink=$(${get_preferred_shell_link})
echo "Detected preferred shell type: $(basename ${pref_shell_reallink})"
echo 'Deploying...'
${deploy_shell} ${pref_shell_reallink}

echo 'Detecting preferred package manager type...'
readonly pref_package_manager_reallink=$(${get_preferred_package_manager_link})
echo "Detected preferred package manager type: $(basename ${pref_package_manager_reallink})"
echo 'Deploying...'
${deploy_package_manager} ${pref_package_manager_reallink}

echo 'Deploying other apps...'
for app in $(${enumaerate_not_deployed_valid_apps}); do
    echo "Deploying $(basename ${app})..."
    ${deploy_app} ${app}
done

echo 'Deployment finished!'
