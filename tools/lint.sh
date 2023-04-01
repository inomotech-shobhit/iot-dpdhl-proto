#!/usr/bin/env bash

_SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")") || exit

main() {
    "$_SCRIPT_DIR/buf.sh" lint --exclude-path sts/v1
}

main "$@"
