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
readonly DEPLOYED_DIR="$(${LIBRARY_SCRIPTS}/get-deployed-directory.sh)"
readonly DEPLOYED_SHELL_LINK="${DEPLOYED_DIR}/shell"

readonly undeploy_app="${SCRIPT_ROOT}/undeploy-app.sh"

readonly shell_link_dst=$(cd $(dirname ${DEPLOYED_SHELL_LINK})/$(readlink ${DEPLOYED_SHELL_LINK}); pwd)

${undeploy_app} ${shell_link_dst}

rm -f ${DEPLOYED_SHELL_LINK}
