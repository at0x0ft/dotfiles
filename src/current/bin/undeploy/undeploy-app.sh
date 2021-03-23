#!/usr/bin/env sh
set -eu

readonly app_undeploy_script="undeploy.sh"

${1}/${app_undeploy_script}

rm -f ${1}
