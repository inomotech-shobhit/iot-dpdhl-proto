#!/usr/bin/env bash

__LIB_SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")") || exit

# shellcheck source=tools/_VERSIONS.sh
source "$__LIB_SCRIPT_DIR/_VERSIONS.sh" || exit

PROJECT_DIR=$(dirname "$__LIB_SCRIPT_DIR") || exit
COMPONENT_BIN_DIR="$PROJECT_DIR/tools/.bin"

running_in_ci() {
    [ "${CI:-}" = "true" ]
}

expand_download_url() {
    local compact_url="${1:?}"

    local github_re="^github:([^:]+):([^:]+)$"
    if [[ $compact_url =~ $github_re ]]; then
        echo "https://github.com/${BASH_REMATCH[1]}/releases/download/${BASH_REMATCH[2]}"
        return 0
    fi

    case "$compact_url" in
    http*)
        echo "$compact_url"
        ;;
    *)
        echo >&2 "ERROR: unrecognized compact url: '$compact_url'"
        return 1
        ;;
    esac
}

detect_archive_type() {
    local name="${1:?}"

    case "$name" in
    *.tar.gz)
        echo "tar.gz"
        ;;
    *.zip)
        echo "zip"
        ;;
    *)
        echo >&2 "ERROR: failed to determine archive type for '$name'"
        return 1
        ;;
    esac
}

download_and_extract() {
    local archive_type="${1:?}"
    local url="${2:?}"
    local target_dir="${3:?}"
    shift 3

    url=$(expand_download_url "$url") || return

    if [ "$archive_type" = "auto" ]; then
        archive_type=$(detect_archive_type "$url") || return
    fi

    local download_file="$target_dir/.download.tmp"
    curl -sSL -o "$download_file" "$url" || return

    mkdir -p "$target_dir" || return
    case "$archive_type" in
    "tar.gz")
        tar -xz -C "$target_dir" -f "$download_file" "$@" || return
        ;;
    "zip")
        unzip -qo "$download_file" "$@" -d "$target_dir" || return
        ;;
    "single-file")
        local file_name="${1:?}"
        mv "$download_file" "$target_dir/$file_name"
        ;;
    *)
        echo >&2 "ERROR: unknown archive type '$archive_type'"
        return 1
        ;;
    esac

    rm -rf "$download_file"
}

download_components() {
    mkdir -p "$COMPONENT_BIN_DIR" || return
    export PATH="$COMPONENT_BIN_DIR:$PATH"

    for component in "$@"; do
        local type_var="${component}_TYPE"
        local archive_type_var="${component}_ARCHIVE_TYPE"
        local url_var="${component}_URL"
        local file_var="${component}_FILE" # set if type=file
        local dir_var="${component}_DIR"   # set if type=dir

        local type="${!type_var:-file}"
        local archive_type="${!archive_type_var:-auto}"
        local url="${!url_var:?}"

        case "$type" in
        "file")
            local file="${!file_var:?}"
            if [ -f "$COMPONENT_BIN_DIR/$file" ]; then
                continue
            fi
            echo >&2 "INFO: downloading component '$component'"
            download_and_extract "$archive_type" "$url" "$COMPONENT_BIN_DIR" "$file" || return
            chmod +x "$COMPONENT_BIN_DIR/$file" || return
            ;;
        "dir")
            local dir_name="${!dir_var:?}"
            local dir_path="$COMPONENT_BIN_DIR/$dir_name"
            if [ -d "$dir_path" ]; then
                continue
            fi
            echo >&2 "INFO: downloading component '$component'"
            mkdir -p "$dir_path" || return
            download_and_extract "$archive_type" "$url" "$dir_path" || return
            ;;
        *)
            echo >&2 "ERROR: unknown component type '$type'"
            return 1
            ;;
        esac

    done
}
