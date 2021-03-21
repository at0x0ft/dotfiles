#!/usr/bin/env sh
set -e

zsh -i -c 'zinit module build; @zinit-scheduler burst || true'
