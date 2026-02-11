#!/usr/bin/env bash
# assert.sh — Guard functions for file system preconditions.
#
# Usage:
#   source assert.sh
#
#   assert_file_exists /path/to/file
#   assert_dir_exists /path/to/dir
#
# Each function prints an error to stderr and returns 1 on failure.
#

[[ -n "${_LIB_ASSERT_LOADED:-}" ]] && return 0
readonly _LIB_ASSERT_LOADED=1

# Assert that a file exists (and is a regular file).
# Usage: assert_file_exists <path>
assert_file_exists() {
    local path="${1:?file path required}"
    [[ -f "$path" ]] || {
        printf "error: file '%s' does not exist\n" "$path" >&2
        return 1
    }
}

# Assert that a directory exists.
# Usage: assert_dir_exists <path>
assert_dir_exists() {
    local path="${1:?directory path required}"
    [[ -d "$path" ]] || {
        printf "error: directory '%s' does not exist\n" "$path" >&2
        return 1
    }
}

# Assert that a path does not already exist.
# Usage: assert_not_exists <path>
assert_not_exists() {
    local path="${1:?path required}"
    [[ ! -e "$path" ]] || {
        printf "error: '%s' already exists\n" "$path" >&2
        return 1
    }
}
