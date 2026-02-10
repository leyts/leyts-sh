#!/usr/bin/env bash
# test_helper.bash — Shared setup for bats tests.
#

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create a temporary directory for each test, cleaned up automatically.
test_helper_setup() {
    TEST_TMPDIR="$(mktemp -d)"
}

# Clean up the temporary directory.
test_helper_teardown() {
    [[ -d "${TEST_TMPDIR:-}" ]] && rm -rf "$TEST_TMPDIR"
}

# Create a minimal git repo in a temp directory.
# Usage: create_test_repo [dir]
# Outputs: path to the repo on stdout.
create_test_repo() {
    local dir="${1:-$TEST_TMPDIR/repo}"
    mkdir -p -- "$dir"
    git -C "$dir" init --quiet
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    echo "test" > "$dir/file.txt"
    git -C "$dir" add .
    git -C "$dir" commit --quiet -m "initial commit"
    echo "$dir"
}
