#!/usr/bin/env sh
set -e

# Usage: ./delete-line.sh delete_content_line dst_file_path
# ${1} = delete_content_line: content line which you want to delete
# ${2} = dst_file_path: path to file which you want to delete content
# calling example: ./make-relative-symlink.sh 'source "/hoge/fuga"' ../../piyo

delete_line() {
    local directive_lineno=$(grep -n "${1}" "${2}" | cut -d ':' -f 1)
    sed -i "${directive_lineno}d" "${2}" && [ ! -s "${2}" ] && rm -f "${2}"
    return 0
}

delete_line "$@"
