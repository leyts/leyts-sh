#!/usr/bin/env bash
# require.sh — General utility and validation functions.
#
# Usage:
#   source require.sh
#

[[ -n "${_LIB_REQUIRE_LOADED:-}" ]] && return 0
readonly _LIB_REQUIRE_LOADED=1

# Assert that a command is available on PATH.
# Usage: require_command <command_name>
# Returns: 0 if found, 1 otherwise (with message to stderr).
require_command() {
    local cmd="${1:?command name required}"
    command -v "$cmd" &>/dev/null || {
        printf "error: required command '%s' not found\n" "$cmd" >&2
        return 1
    }
}

# Prompt the user for yes/no confirmation.
# Usage: confirm "Do something dangerous?"
# Returns: 0 if confirmed, 1 otherwise.
confirm() {
    local prompt="${1:-Proceed?}"
    local reply
    read -p "$prompt [y/N] " -n 1 -r reply
    echo >&2
    [[ "$reply" =~ ^[Yy]$ ]]
}
