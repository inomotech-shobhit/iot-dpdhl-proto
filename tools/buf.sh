#!/usr/bin/env bash

_SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")") || exit

# shellcheck source=tools/_lib.sh
source "$_SCRIPT_DIR/_lib.sh" || exit

# used by `download_components`
export BUF_FILE="buf"
export BUF_ARCHIVE_TYPE="single-file"
export BUF_URL="github:bufbuild/buf:v${BUF_VERSION}/buf-Linux-x86_64"

export PROTOC_TYPE="dir"
export PROTOC_DIR="protoc"
export PROTOC_URL="github:protocolbuffers/protobuf:v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip"

protoc_post_download() {
    local protoc_bin_dir="$COMPONENT_BIN_DIR/$PROTOC_DIR/bin"
    chmod +x "$protoc_bin_dir/protoc" || return
    export PATH="$protoc_bin_dir:$PATH"
}

main() {
    local is_generate="0"
    local required_components=("BUF")

    if [ "${1:-}" = "generate" ]; then
        is_generate="1"
        required_components+=("PROTOC")
    fi

    download_components "${required_components[@]}" || return

    local extra_args=()
    if [ "$is_generate" -eq "1" ]; then
        # perform post-installation steps for protoc
        protoc_post_download || return
        extra_args+=("--exclude-path" "$PROJECT_DIR/tools")
    fi

    buf "$@" "${extra_args[@]}" || return
}

main "$@"
