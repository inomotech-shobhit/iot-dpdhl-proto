#!/usr/bin/env bash

_SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")") || exit

# shellcheck source=tools/_lib.sh
source "$_SCRIPT_DIR/_lib.sh" || exit

# used by `download_components`
export MDBOOK_ADMONISH_FILE="mdbook-admonish"
export MDBOOK_ADMONISH_URL="github:tommilligan/mdbook-admonish:v${MDBOOK_ADMONISH_VERSION}/mdbook-admonish-v${MDBOOK_ADMONISH_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
export MDBOOK_FILE="mdbook"
export MDBOOK_KATEX_FILE="mdbook-katex"
export MDBOOK_KATEX_URL="github:lzanini/mdbook-katex:v${MDBOOK_KATEX_VERSION}/mdbook-katex-v${MDBOOK_KATEX_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
export MDBOOK_LINKCHECK_FILE="mdbook-linkcheck"
export MDBOOK_LINKCHECK_URL="github:Michael-F-Bryan/mdbook-linkcheck:v${MDBOOK_LINKCHECK_VERSION}/mdbook-linkcheck.x86_64-unknown-linux-gnu.zip"
export MDBOOK_PDF_ARCHIVE_TYPE="single-file"
export MDBOOK_PDF_FILE="mdbook-pdf"
export MDBOOK_PDF_URL="github:HollowMan6/mdbook-pdf:v${MDBOOK_PDF_VERSION}/mdbook-pdf-v${MDBOOK_PDF_VERSION}-x86_64-unknown-linux-musl"
export MDBOOK_URL="github:rust-lang/mdBook:v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz"

_NEEDS_DIR=(
    "build"
    "clean"
    "serve"
    "test"
    "watch"
)

cmd_needs_dir_arg() {
    local cmd="${1:?}"
    for c in "${_NEEDS_DIR[@]}"; do
        if [ "$c" = "$cmd" ]; then
            return 0
        fi
    done
    return 1
}

replace_version_template() {
    local version=${CI_COMMIT_TAG:-""}
    if [ -z "$version" ]; then
        local branch=${CI_COMMIT_BRANCH:-"unknown"}
        version="${branch}#${CI_COMMIT_SHORT_SHA:-"unknown"}"
    fi

    local escaped_version
    escaped_version=$(printf '%s\n' "$version" | sed -e 's/[]\/$*.^[]/\\&/g') || return

    local date_today
    date_today=$(date --iso-8601=date) || return

    sed \
        -i \
        -e "s/{{VERSION}}/$escaped_version/g" \
        -e "s/{{DATE}}/$date_today/g" \
        "$PROJECT_DIR/docs/book.toml" || return
}

main() {
    download_components \
        "MDBOOK" \
        "MDBOOK_ADMONISH" \
        "MDBOOK_KATEX" \
        "MDBOOK_LINKCHECK" \
        "MDBOOK_PDF" || return

    if running_in_ci; then
        replace_version_template || return
    fi

    echo >&2 "INFO: running mdbook"
    if [ -n "$1" ] && cmd_needs_dir_arg "$1"; then
        mdbook "$@" "$PROJECT_DIR/docs" || return
    else
        mdbook "$@" || return
    fi
}

main "$@"
