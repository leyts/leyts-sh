#!/usr/bin/env bash
# podman.sh — Podman container and image helper functions.
#
# Usage:
#   source podman.sh
#
# On failure, functions return a non-zero exit code and write to stderr.
# On success, output is written to stdout.
#

[[ -n "${_LIB_PODMAN_LOADED:-}" ]] && return 0
readonly _LIB_PODMAN_LOADED=1

# Check whether a container exists (any state).
# Usage: podman_container_exists <name>
# Returns: 0 if exists, 1 otherwise.
podman_container_exists() {
    local name="${1:?container name required}"
    podman container inspect "$name" &>/dev/null
}

# Check whether a container is currently running.
# Usage: podman_container_is_running <name>
# Returns: 0 if running, 1 otherwise.
podman_container_is_running() {
    local name="${1:?container name required}"
    local state
    state=$(podman container inspect --format '{{ .State.Running }}' "$name" 2>/dev/null) || return 1
    [[ "$state" == 'true' ]]
}

# Get the full container ID.
# Usage: podman_get_container_id <name>
# Outputs: container ID on stdout.
podman_get_container_id() {
    local name="${1:?container name required}"
    local cid
    cid=$(podman container inspect --format '{{ .Id }}' "$name" 2>/dev/null) || {
        printf "error: container '%s' not found\n" "$name" >&2
        return 1
    }
    echo "$cid"
}

# Get the image used by a container.
# Usage: podman_get_container_image <name>
# Outputs: image name on stdout.
podman_get_container_image() {
    local name="${1:?container name required}"
    local image
    image=$(podman container inspect --format '{{ .ImageName }}' "$name" 2>/dev/null) || {
        printf "error: container '%s' not found\n" "$name" >&2
        return 1
    }
    [[ -n "$image" ]] || {
        printf "error: no image found for container '%s'\n" "$name" >&2
        return 1
    }
    echo "$image"
}

# Get an OCI annotation from an image.
# Usage: podman_get_image_annotation <image> <annotation_key>
# Outputs: annotation value on stdout.
podman_get_image_annotation() {
    local image="${1:?image name required}"
    local key="${2:?annotation key required}"
    local value
    value=$(podman image inspect "$image" --format "{{ index .Annotations "'"$key"'" }}" 2>/dev/null) || {
        printf "error: image '%s' not found\n" "$image" >&2
        return 1
    }
    [[ -n "$value" ]] || {
        printf "error: annotation '%s' not found on image '%s'\n" "$key" "$image" >&2
        return 1
    }
    echo "$value"
}
