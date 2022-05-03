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
readonly ZINIT_PATH="${HOME}/.local/share/zinit"

# later implement installing zinit
printf "[Debug]: called zinit/uninstall.sh with ${1}\n" >&2
# printf "[Debug]: uninstall requirements packages (libncurses-dev, unzip, curl, file, gcc, make, autoconf) with ${1}...\n" >&2

printf "Uninstalling zinit...\n"
rm -rf "${ZINIT_PATH}"
