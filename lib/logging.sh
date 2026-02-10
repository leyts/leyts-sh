#!/usr/bin/env bash
# logging.sh — Structured logging with level filtering and colour support.
#
# Usage:
#   source logging.sh
#
#   log_info "Starting deployment..."
#   log_warn "Config file missing, using defaults"
#   log_error "Connection refused"
#   log_debug "Resolved image: $image"
#
# Configuration (via environment variables):
#   LOG_LEVEL   — Minimum level to display: DEBUG, INFO, WARN, ERROR (default: INFO)
#   NO_COLOR    — Set to any value to disable colour
#

[[ -n "${_LIB_LOGGING_LOADED:-}" ]] && return 0
readonly _LIB_LOGGING_LOADED=1

# --- Level definitions ---

readonly _LOG_LEVEL_DEBUG=0
readonly _LOG_LEVEL_INFO=1
readonly _LOG_LEVEL_WARN=2
readonly _LOG_LEVEL_ERROR=3

: "${LOG_LEVEL:=INFO}"

# --- Colour setup ---

_log_init_colour() {
    _LOG_CLR_RESET=''
    _LOG_CLR_DEBUG=''
    _LOG_CLR_INFO=''
    _LOG_CLR_WARN=''
    _LOG_CLR_ERROR=''

    # Respect NO_COLOR
    [[ -n "${NO_COLOR:-}" ]] && return 0

    # Only colourise if stderr is a terminal.
    [[ -t 2 ]] || return 0

    _LOG_CLR_RESET=$'\033[0m'
    _LOG_CLR_DEBUG=$'\033[36m'  # cyan
    _LOG_CLR_INFO=$'\033[32m'   # green
    _LOG_CLR_WARN=$'\033[33m'   # yellow
    _LOG_CLR_ERROR=$'\033[31m'  # red
}

_log_init_colour

# --- Internal ---

_log_level_to_int() {
    case "${1^^}" in
        DEBUG) printf '%s' "$_LOG_LEVEL_DEBUG" ;;
        INFO)  printf '%s' "$_LOG_LEVEL_INFO"  ;;
        WARN)  printf '%s' "$_LOG_LEVEL_WARN"  ;;
        ERROR) printf '%s' "$_LOG_LEVEL_ERROR" ;;
        *)     printf '%s' "$_LOG_LEVEL_INFO"  ;;
    esac
}

_log() {
    local level="$1" colour="$2"
    shift 2
    local message="$*"

    local min_level
    min_level=$(_log_level_to_int "$LOG_LEVEL")
    local msg_level
    msg_level=$(_log_level_to_int "$level")

    (( msg_level >= min_level )) || return 0

    local label
    label=$(printf '%-5s' "$level")

    printf '%s[%s]%s %s\n' "$colour" "$label" "$_LOG_CLR_RESET" "$message" >&2
}

# --- Public API ---

# Set the active log level with validation.
# Usage: set_log_level <level>
set_log_level() {
    local level="${1:?log level required}"
    case "$level" in
        DEBUG|INFO|WARN|ERROR) LOG_LEVEL="$level" ;;
        *)
            printf "error: invalid log level '%s' (expected DEBUG, INFO, WARN, ERROR)\n" "$level" >&2
            return 1
            ;;
    esac
}

# Execute a command, suppressing output if below the current log level.
# Usage: log_execute <level> <command> [args...]
# If the current level is higher than the specified level, stdout and stderr
# are redirected to /dev/null. Otherwise the command runs normally.
log_execute() {
    local level="${1:?log level required}"
    shift

    local min_level
    min_level=$(_log_level_to_int "$LOG_LEVEL")
    local cmd_level
    cmd_level=$(_log_level_to_int "$level")

    if (( cmd_level >= min_level )); then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

log_debug() { _log DEBUG "$_LOG_CLR_DEBUG" "$@"; }
log_info()  { _log INFO  "$_LOG_CLR_INFO"  "$@"; }
log_warn()  { _log WARN  "$_LOG_CLR_WARN"  "$@"; }
log_error() { _log ERROR "$_LOG_CLR_ERROR" "$@"; }
