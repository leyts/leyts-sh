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
#   LOG_HANDLER — Output handler: console, json (default: console)
#   NO_COLOR    — Set to any value to disable colour
#

[[ -n "${_LIB_LOGGING_LOADED:-}" ]] && return 0
readonly _LIB_LOGGING_LOADED=1

# --- Level definitions ---

declare -grA _LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [WARN]=2
    [ERROR]=3
)

: "${LOG_LEVEL:=INFO}"
: "${LOG_HANDLER:=console}"

# --- Handler setup ---

_log_init_handler() {
    case "$LOG_HANDLER" in
        console) _LOG_HANDLER='console' ;;
        json)
            command -v jq &>/dev/null || {
                printf "ERROR: LOG_HANDLER=json requires jq\n" >&2
                return 1
            }
            _LOG_HANDLER='json'
            ;;
        *)
            printf "ERROR: invalid LOG_HANDLER '%s'\n" \
                "$LOG_HANDLER" >&2
            return 1
            ;;
    esac
}

_log_init_handler || return 1

# --- Colour setup ---

declare -gA _LOG_CLR=()

_log_init_colour() {
    _LOG_CLR=([DEBUG]='' [INFO]='' [WARN]='' [ERROR]='')

    # Respect NO_COLOR
    [[ -n "${NO_COLOR:-}" ]] && return 0

    # Only colourise if stderr is a terminal.
    [[ -t 2 ]] || return 0

    _LOG_CLR_RESET=$'\033[0m' # TODO: Make name clearer?
    _LOG_CLR[DEBUG]=$'\033[36m'  # cyan
    _LOG_CLR[INFO]=$'\033[32m'   # green
    _LOG_CLR[WARN]=$'\033[33m'   # yellow
    _LOG_CLR[ERROR]=$'\033[31m'  # red
}

_log_init_colour

# --- Handlers ---

_log_handler_console() {
    local level="$1"
    local message="$2"
    local colour="${_LOG_CLR["$level"]}"
    printf '%s[%-5s]%s %s\n' \
        "$colour" "$level" "$_LOG_CLR_RESET" "$message" >&2
}

_log_handler_json() {
    jq -nc \
        --arg lvl "$1" \
        --arg msg "$2" \
        '{
            "timestamp": (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
            "level": $lvl,
            "message": $msg
        }' >&2
}

# --- Internal ---

_log_validate_log_level() {
    local level="$1"
    if ! [[ -n "${_LOG_LEVELS[$level]:-}" ]]; then
        printf "ERROR: invalid log level '%s'\n" "$level" >&2
        return 1
    fi
}

_log() {
    local level="$1"
    shift
    local message="$*"

    local min_level=${_LOG_LEVELS[$LOG_LEVEL]:-${_LOG_LEVELS[INFO]}}
    local msg_level=${_LOG_LEVELS[$level]}
    (( msg_level >= min_level )) || return 0

    case "$_LOG_HANDLER" in
        console) _log_handler_console "$level" "$message" ;;
        json)    _log_handler_json    "$level" "$message" ;;
    esac
}

# --- Public API ---

# Set the active log level with validation.
# Usage: set_log_level <level>
set_log_level() {
    local level="${1:?log level required}"
    _log_validate_log_level "$level" || return 1
    LOG_LEVEL="$level"
}

# Execute a command, suppressing output if below the current log level.
# Usage: log_execute <level> <command> [args...]
# If the current level is higher than the specified level, stdout and stderr
# are redirected to /dev/null. Otherwise the command runs normally.
log_execute() {
    local level="${1:?log level required}"
    _log_validate_log_level "$level" || return 1
    shift

    local min_level=${_LOG_LEVELS[$LOG_LEVEL]:-${_LOG_LEVELS[INFO]}}
    local cmd_level=${_LOG_LEVELS[$level]}

    if (( cmd_level >= min_level )); then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO  "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }
