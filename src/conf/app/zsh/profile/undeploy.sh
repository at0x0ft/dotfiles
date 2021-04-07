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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly ZPROFILE_PATH="${HOME}/.zprofile"
readonly ZSH_BACKUP_PATH="${CURRENT_ROOT}/bak/zsh"
readonly BACKUP_DST_PATH="${ZSH_BACKUP_PATH}/zprofile"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly GENERAL_PATH="${SCRIPT_ROOT}/general.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
readonly GENERAL_DIRECTIVE="source '${GENERAL_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"

readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

restore() {
    if [ -f "${BACKUP_DST_PATH}" ]; then
        mv "${BACKUP_DST_PATH}" "${ZPROFILE_PATH}"
    fi

    if [ -d "${ZSH_BACKUP_PATH}" ] && [ -z "$(ls "${ZSH_BACKUP_PATH}")" ]; then
        rmdir "${ZSH_BACKUP_PATH}"
    fi
}

rm "${ZPROFILE_PATH}"

${delete_line} "${EXTERNAL_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${GENERAL_DIRECTIVE}" "${RC_PATH}"
if [ ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
fi

restore
