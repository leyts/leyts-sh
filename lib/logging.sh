#!/usr/bin/env bash
# logging.sh — Structured logging with level filtering and colour support.
#
# Usage:
#   source logging.sh
#
#   log_debug "Resolved image: $image"
#   log_info 'Starting deployment...'
#   log_warn 'Config file missing, using defaults'
#   log_error 'Connection refused'
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
            command -v jq >/dev/null 2>&1 || {
                printf "error: LOG_HANDLER=json requires jq\n" >&2
                return 1
            }
            _LOG_HANDLER='json'
            ;;
        *)
            printf "error: invalid LOG_HANDLER '%s'\n" \
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
    local lvl="$1"
    local msg="$2"
    local clr="${_LOG_CLR["$lvl"]}"
    printf '%s[%-5s]%s %s\n' \
        "$clr" "$lvl" "$_LOG_CLR_RESET" "$msg" >&2
}

_log_handler_json() {
    local lvl="$1"
    local msg="$2"
    jq -nc \
        --arg lvl "$lvl" \
        --arg msg "$msg" \
        '{
            "timestamp": (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
            "level": $lvl,
            "message": $msg
        }' >&2
}

# --- Internal ---

_log_validate_log_level() {
    local lvl="$1"
    if ! [[ -n "${_LOG_LEVELS[$lvl]:-}" ]]; then
        printf "error: invalid log level '%s'\n" "$lvl" >&2
        return 1
    fi
}

_log() {
    local lvl="$1"
    shift

    local min_lvl=${_LOG_LEVELS[$LOG_LEVEL]:-${_LOG_LEVELS[INFO]}}
    local msg_lvl=${_LOG_LEVELS[$lvl]}
    (( msg_lvl >= min_lvl )) || return 0

    local msg="$*"
    case "$_LOG_HANDLER" in
        console) _log_handler_console "$lvl" "$msg" ;;
        json)    _log_handler_json    "$lvl" "$msg" ;;
    esac
}

# --- Public API ---

# Set the active log level with validation.
# Usage: set_log_level <level>
set_log_level() {
    local lvl="${1:?log level required}"
    _log_validate_log_level "$lvl" || return 1
    LOG_LEVEL="$lvl"
}

# Execute a command, suppressing output if below the current log level.
# Usage: log_execute <level> <command> [args...]
# If the current level is higher than the specified level, stdout and stderr
# are redirected to /dev/null. Otherwise the command runs normally.
log_execute() {
    local lvl="${1:?log level required}"
    _log_validate_log_level "$lvl" || return 1
    shift

    local min_lvl=${_LOG_LEVELS[$LOG_LEVEL]:-${_LOG_LEVELS[INFO]}}
    local cmd_lvl=${_LOG_LEVELS[$lvl]}

    if (( cmd_lvl >= min_lvl )); then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO  "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }
