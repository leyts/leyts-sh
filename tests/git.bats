#!/usr/bin/env bats

load test_helper

setup() {
    test_helper_setup
    source "$REPO_ROOT/lib/git.sh"
}

teardown() {
    test_helper_teardown
}

# --- git_get_revision ---

@test "git_get_revision returns full SHA" {
    local repo
    repo=$(create_test_repo)
    run git_get_revision "$repo"
    [[ "$status" -eq 0 ]]
    [[ "${#output}" -eq 40 ]]
}

@test "git_get_revision fails for non-existent directory" {
    run git_get_revision "/nonexistent/path"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"does not exist"* ]]
}

@test "git_get_revision fails for non-git directory" {
    mkdir -p -- "$TEST_TMPDIR/notrepo"
    run git_get_revision "$TEST_TMPDIR/notrepo"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"not a git repository"* ]]
}

@test "git_get_revision fails without argument" {
    run git_get_revision
    [[ "$status" -ne 0 ]]
}

# --- git_get_short_revision ---

@test "git_get_short_revision returns short SHA" {
    local repo
    repo=$(create_test_repo)
    run git_get_short_revision "$repo"
    [[ "$status" -eq 0 ]]
    (( ${#output} >= 7 && ${#output} <= 12 ))
}

