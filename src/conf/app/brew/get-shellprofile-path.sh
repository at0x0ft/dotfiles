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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

# reference: https://github.com/Homebrew/install/blob/master/install.sh#L722
get_shellprofile_path() {
    local login_shell="$(basename "$("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh")")"
    local profile_name=''
    case "${login_shell}" in
        bash*)
            if [[ -r "${HOME}/.bash_profile" ]]; then
                profile_name='.bash_profile'
            else
                profile_name='.profile'
            fi
            ;;
        zsh*)
            profile_name='.zprofile'
            ;;
        *)
            profile_name='.profile'
            ;;
    esac
    printf '%s/%s' ${HOME} ${profile_name}
}

get_shellprofile_path
