#!/usr/bin/env bash

_SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")") || exit

# shellcheck source=tools/_lib.sh
source "$_SCRIPT_DIR/_lib.sh" || exit

# used by `download_components`
export RELEASE_FILE="release"
export RELEASE_URL="github:tomodian/release:${RELEASE_VERSION}/release_linux_amd64.zip"

main() {
    download_components "RELEASE" || return
    release "$@" || return
}

main "$@"
