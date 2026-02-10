#!/usr/bin/env bats

load test_helper

setup() {
    source "$REPO_ROOT/lib/require.sh"
}

# --- require_command ---

@test "require_command succeeds for bash" {
    run require_command bash
    [[ "$status" -eq 0 ]]
}

@test "require_command fails for nonexistent command" {
    run require_command nonexistent_command_xyz
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"not found"* ]]
}

@test "require_command fails without argument" {
    run require_command
    [[ "$status" -ne 0 ]]
}

# --- confirm ---

@test "confirm returns 0 on 'y'" {
    run bash -c 'source '"$REPO_ROOT"'/lib/require.sh; echo y | confirm "test?"'
    [[ "$status" -eq 0 ]]
}

@test "confirm returns 1 on 'n'" {
    run bash -c 'source '"$REPO_ROOT"'/lib/require.sh; echo n | confirm "test?"'
    [[ "$status" -ne 0 ]]
}

@test "confirm returns 1 on empty input" {
    run bash -c 'source '"$REPO_ROOT"'/lib/require.sh; echo "" | confirm "test?"'
    [[ "$status" -ne 0 ]]
}
