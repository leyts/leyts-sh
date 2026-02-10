#!/usr/bin/env bats

load test_helper

setup() {
    source "$REPO_ROOT/lib/logging.sh"
}

# --- Level filtering ---

@test "log_info outputs at default level" {
    run log_info "hello"
    [[ "$output" == *"[INFO ]"*"hello"* ]]
}

@test "log_debug is hidden at default level" {
    run log_debug "hidden"
    [[ -z "$output" ]]
}

@test "log_debug is visible when LOG_LEVEL=DEBUG" {
    LOG_LEVEL=DEBUG
    run log_debug "visible"
    [[ "$output" == *"[DEBUG]"*"visible"* ]]
}

@test "log_warn is visible at default level" {
    run log_warn "caution"
    [[ "$output" == *"[WARN ]"*"caution"* ]]
}

@test "log_error is visible at default level" {
    run log_error "failure"
    [[ "$output" == *"[ERROR]"*"failure"* ]]
}

@test "log_info is hidden when LOG_LEVEL=WARN" {
    LOG_LEVEL=WARN
    run log_info "hidden"
    [[ -z "$output" ]]
}

# --- set_log_level ---

@test "set_log_level accepts valid levels" {
    run set_log_level DEBUG
    [[ "$status" -eq 0 ]]
    run set_log_level INFO
    [[ "$status" -eq 0 ]]
    run set_log_level WARN
    [[ "$status" -eq 0 ]]
    run set_log_level ERROR
    [[ "$status" -eq 0 ]]
}

@test "set_log_level is case-insensitive" {
    run set_log_level debug
    [[ "$status" -eq 0 ]]
}

@test "set_log_level rejects invalid levels" {
    run set_log_level BOGUS
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"invalid log level"* ]]
}

# --- log_execute ---

@test "log_execute shows output at matching level" {
    LOG_LEVEL=DEBUG
    run log_execute DEBUG echo "visible"
    [[ "$output" == "visible" ]]
}

@test "log_execute suppresses output below current level" {
    LOG_LEVEL=WARN
    run log_execute DEBUG echo "hidden"
    [[ -z "$output" ]]
}

# --- Edge cases ---

@test "messages with backslash-n are printed literally" {
    run log_info 'contains \n newline'
    [[ "$output" == *'\n'* ]]
}

@test "messages starting with -n are printed correctly" {
    run log_info "-n flag"
    [[ "$output" == *"-n flag"* ]]
}

@test "messages starting with -e are printed correctly" {
    run log_info "-e flag"
    [[ "$output" == *"-e flag"* ]]
}
