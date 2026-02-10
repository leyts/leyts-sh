#!/usr/bin/env bats

load test_helper

setup() {
    test_helper_setup
    source "$REPO_ROOT/lib/assert.sh"
}

teardown() {
    test_helper_teardown
}

# --- assert_file_exists ---

@test "assert_file_exists succeeds for existing file" {
    touch "$TEST_TMPDIR/file"
    run assert_file_exists "$TEST_TMPDIR/file"
    [[ "$status" -eq 0 ]]
}

@test "assert_file_exists fails for missing file" {
    run assert_file_exists "$TEST_TMPDIR/missing"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"does not exist"* ]]
}

@test "assert_file_exists fails for directory" {
    mkdir "$TEST_TMPDIR/dir"
    run assert_file_exists "$TEST_TMPDIR/dir"
    [[ "$status" -ne 0 ]]
}

@test "assert_file_exists fails without argument" {
    run assert_file_exists
    [[ "$status" -ne 0 ]]
}

# --- assert_dir_exists ---

@test "assert_dir_exists succeeds for existing directory" {
    mkdir "$TEST_TMPDIR/dir"
    run assert_dir_exists "$TEST_TMPDIR/dir"
    [[ "$status" -eq 0 ]]
}

@test "assert_dir_exists fails for missing directory" {
    run assert_dir_exists "$TEST_TMPDIR/missing"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"does not exist"* ]]
}

@test "assert_dir_exists fails for regular file" {
    touch "$TEST_TMPDIR/file"
    run assert_dir_exists "$TEST_TMPDIR/file"
    [[ "$status" -ne 0 ]]
}

@test "assert_dir_exists fails without argument" {
    run assert_dir_exists
    [[ "$status" -ne 0 ]]
}

# --- assert_not_exists ---

@test "assert_not_exists succeeds for missing path" {
    run assert_not_exists "$TEST_TMPDIR/missing"
    [[ "$status" -eq 0 ]]
}

@test "assert_not_exists fails for existing file" {
    touch "$TEST_TMPDIR/file"
    run assert_not_exists "$TEST_TMPDIR/file"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"already exists"* ]]
}

@test "assert_not_exists fails for existing directory" {
    mkdir "$TEST_TMPDIR/dir"
    run assert_not_exists "$TEST_TMPDIR/dir"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"already exists"* ]]
}

@test "assert_not_exists fails without argument" {
    run assert_not_exists
    [[ "$status" -ne 0 ]]
}
