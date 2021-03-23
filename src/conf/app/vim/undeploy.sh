#!/usr/bin/env sh
set -e

readonly VIMRC_PATH="${HOME}/.vimrc"

[ -L ${VIMRC_PATH} ] && rm -f ${VIMRC_PATH}

return 0
