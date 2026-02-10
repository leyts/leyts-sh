#!/usr/bin/env bash
# git.sh — Git helper functions.
#
# Usage:
#   source git.sh
#
# On failure, functions return a non-zero exit code and write to stderr.
# On success, output is written to stdout.
#

[[ -n "${_LIB_GIT_LOADED:-}" ]] && return 0
readonly _LIB_GIT_LOADED=1

# Get the HEAD revision of a Git repository.
# Usage: git_get_revision <repo_path> [rev-parse args...]
# Outputs: SHA on stdout.
# Example: git_get_revision /path/to/repo --short
git_get_revision() {
    local repo_path="${1:?repository path required}"
    shift
    local rev
    [[ -d "$repo_path" ]] || {
        printf "error: directory '%s' does not exist\n" "$repo_path" >&2
        return 1
    }
    rev=$(git -C "$repo_path" rev-parse "$@" HEAD 2>&1) || {
        printf "error: failed to get revision for '%s': %s\n" "$repo_path" "$rev" >&2
        return 1
    }
    echo "$rev"
}

# Get the short HEAD revision of a Git repository.
# Usage: git_get_short_revision <repo_path>
# Outputs: short SHA on stdout.
git_get_short_revision() {
    git_get_revision "$1" --short
}
