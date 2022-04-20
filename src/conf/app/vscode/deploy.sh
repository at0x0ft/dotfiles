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
readonly SCRIPT_ROOT="$(dirname -- ${SCRIPT_PATH})"
readonly OS_TYPE_MACOS_VALUE='mac'
readonly OS_TYPE_LINUX_VALUE='lin'
readonly MACOS_SETTINGS_DESTINATION_PATH="${HOME}/Library/Application Support/Code/User/settings.json"
readonly LINUX_SETTINGS_DESTINATION_PATH="${HOME}/.config/Code/User/settings.json"
readonly MACOS_KEYBINDINGS_DESTINATION_PATH="${HOME}/Library/Application Support/Code/User/keybindings.json"
readonly LINUX_KEYBINDINGS_DESTINATION_PATH="${HOME}/.config/Code/User/keybindings.json"
readonly EXTENSIONS_FILE_PATH="${SCRIPT_ROOT}/extensions"

get_os_type() {
    local readonly uname_result=$(uname)
    if [ "${uname_result}" = "Darwin" ]; then
        printf '%s' "${OS_TYPE_MACOS_VALUE}"
    else
        printf '%s' "${OS_TYPE_LINUX_VALUE}"
    fi
    return 0
}

readonly os_type=$(get_os_type)

get_settings_source_path() {
    printf '%s/settings.%s.json' "${SCRIPT_ROOT}" "${1}"
    return 0
}

get_settings_destination_path() {
    if [ "${1}" = "${OS_TYPE_MACOS_VALUE}" ]; then
        printf '%s' "${MACOS_SETTINGS_DESTINATION_PATH}"
    else
        printf '%s' "${LINUX_SETTINGS_DESTINATION_PATH}"
    fi
    return 0
}

get_keybindings_source_path() {
    printf '%s/keybindings.%s.json' "${SCRIPT_ROOT}" "${1}"
    return 0
}

get_keybindings_destination_path() {
    if [ "${1}" = "${OS_TYPE_MACOS_VALUE}" ]; then
        printf '%s' "${MACOS_KEYBINDINGS_DESTINATION_PATH}"
    else
        printf '%s' "${LINUX_KEYBINDINGS_DESTINATION_PATH}"
    fi
    return 0
}

ln -snvf "$(get_settings_source_path ${os_type})" "$(get_settings_destination_path ${os_type})"
ln -snvf "$(get_keybindings_source_path ${os_type})" "$(get_keybindings_destination_path ${os_type})"
for extension_id in $(cat "${EXTENSIONS_FILE_PATH}"); do
    code --install-extension "${extension_id}"
done
