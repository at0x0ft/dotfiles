#!/bin/bash -e
set -o pipefail

function delete_password() {
    unset sudo_password
    sudo -K
}
trap delete_password EXIT

function receive_sudo_password() {
    printf "[sudo] password for `whoami`: "
    read -s sudo_password
    echo ""
}

function sudo_exec() {
    echo "$sudo_password" | sudo -S $@ 2>/dev/null
}
