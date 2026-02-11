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

@test "set_log_level rejects lowercase" {
    run set_log_level debug
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"invalid log level"* ]]
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

# --- LOG_HANDLER ---

@test "LOG_HANDLER defaults to console" {
    run log_info "hello"
    [[ "$output" == *"[INFO ]"*"hello"* ]]
}

@test "invalid LOG_HANDLER is rejected" {
    run bash -c 'LOG_HANDLER=bogus source "$1/lib/logging.sh"' _ "$REPO_ROOT"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"invalid LOG_HANDLER"* ]]
}

@test "LOG_HANDLER=json fails when jq is not available" {
    run bash -c 'PATH=/nonexistent LOG_HANDLER=json source "$1/lib/logging.sh"' _ "$REPO_ROOT"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"requires jq"* ]]
}

# --- JSON handler ---

@test "JSON handler outputs valid parseable JSON" {
    run bash -c 'LOG_HANDLER=json source "$1/lib/logging.sh" && log_info "hello json"' _ "$REPO_ROOT"
    jq -e . <<<"$output"
}

@test "JSON output contains correct timestamp, level and message fields" {
    run bash -c 'LOG_HANDLER=json source "$1/lib/logging.sh" && log_warn "test msg"' _ "$REPO_ROOT"
    local ts level msg
    ts=$(jq -r '.timestamp' <<<"$output")
    level=$(jq -r '.level' <<<"$output")
    msg=$(jq -r '.message' <<<"$output")
    [[ "$ts" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]
    [[ "$level" == "WARN" ]]
    [[ "$msg" == "test msg" ]]
}

@test "JSON handler escapes special characters" {
    run bash -c 'LOG_HANDLER=json source "$1/lib/logging.sh" && log_info "quote\"slash\\"' _ "$REPO_ROOT"
    jq -e . <<<"$output"
    local msg
    msg=$(jq -r '.message' <<<"$output")
    [[ "$msg" == 'quote"slash\' ]]
}

