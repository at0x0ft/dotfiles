#!/usr/bin/env sh
set -e

# Usage: ./make-relative-symlink.sh [-a] symlink_origin_path symlink_destination_path
# ${1} = symlink_origin_path: symlink origin path
# ${2} = symlink_destination_path: symlink destination path
# option -a: expand all symlink to absolute path.
# calling example: ./make-relative-symlink.sh -a hoge ../../piyo (expand all symlinks)
#                : ./make-relative-symlink.sh fuga ../../nyan (not expand all symlinks)

expand_symlink=false
print_wd() {
    if ${expand_symlink}; then
        pwd -P
    else
        pwd
    fi
}

while getopts a OPT; do
    case ${OPT} in
        a )
            expand_symlink=true
            cd $(print_wd)
            shift
            ;;
        * )
            echo '[Error]: unknown option given.' >&2
            exit 1
            ;;
    esac
done

get_abspath() {
    local path=${1}
    if [ ! -d ${path} ]; then
        echo "$(cd $(dirname ${path}); print_wd)/$(basename ${path})"
    else
        echo "$(cd ${path}; print_wd)"
    fi
}

is_ancestor_path() {
    echo ${2} | grep "^${1}"
}

get_relpath_from() {
    local org_path=$(get_abspath ${1})
    local dst_path=$(get_abspath ${2})
    local result=''
    while [ ! ${org_path} = '/' -a ! $(is_ancestor_path ${org_path} ${dst_path}) ]; do
        [ ! ${result} = '' ] && result="${result}/"
        org_path=$(cd "${org_path}/.."; print_wd)
        result="${result}.."
    done
    dst_path=$(echo ${dst_path} | sed -e "s%^${org_path}%%g")
    if [ ! "${result}" = '' ]; then
        echo "${result}${dst_path}"
    else
        echo "${dst_path#/}"
    fi
}

cd $(pwd -P)
readonly link_name=$(basename ${1})
readonly linkbase_dir=$(get_abspath $(dirname ${1}))
readonly relpath=$(get_relpath_from ${linkbase_dir} ${2})

cd ${linkbase_dir}
ln -snvf ${relpath} ${link_name}
