#!/usr/bin/env sh
set -e

# readonly SCRIPT_PATH=$(
#     self=${0}
#     while [ -L "${self}" ]; do
#         cd "${self%/*}"
#         self=$(readlink "${self}")
#     done
#     cd "${self%/*}"
#     echo "$(pwd -P)/${self##*/}"
# )
# readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
# readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)
# readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
# readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
# readonly BREWRC_PATH="${SCRIPT_ROOT}/rc.sh"
# readonly EXEC_COMMAND="$(basename ${SCRIPT_ROOT})"

# readonly is_valid_command="${CURRENT_LIBRARY_SCRIPTS}/is_valid_command.sh"

# . ${BREWRC_PATH}

# if $(${is_valid_command} ${EXEC_COMMAND}); then
#     echo true
# else
#     echo false
# fi


# later implement installing zinit
printf "[Debug]: called zinit/initialize.sh\n" >&2
