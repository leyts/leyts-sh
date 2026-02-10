#!/usr/bin/env bats

load test_helper

setup() {
    source "$REPO_ROOT/lib/podman.sh"
}

# --- Argument validation ---

@test "podman_container_exists fails without argument" {
    run podman_container_exists
    [[ "$status" -ne 0 ]]
}

@test "podman_container_is_running fails without argument" {
    run podman_container_is_running
    [[ "$status" -ne 0 ]]
}

@test "podman_get_container_id fails without argument" {
    run podman_get_container_id
    [[ "$status" -ne 0 ]]
}

@test "podman_get_container_image fails without argument" {
    run podman_get_container_image
    [[ "$status" -ne 0 ]]
}

@test "podman_get_image_annotation fails without image argument" {
    run podman_get_image_annotation
    [[ "$status" -ne 0 ]]
}

@test "podman_get_image_annotation fails without key argument" {
    run podman_get_image_annotation "myimage"
    [[ "$status" -ne 0 ]]
}

# --- With mock podman ---

@test "podman_container_exists returns 0 when container exists" {
    podman() { [[ "$1 $2" == "container inspect" ]] && return 0; }
    export -f podman
    run podman_container_exists "mycontainer"
    [[ "$status" -eq 0 ]]
}

@test "podman_container_exists returns 1 when container missing" {
    podman() { return 1; }
    export -f podman
    run podman_container_exists "missing"
    [[ "$status" -ne 0 ]]
}

@test "podman_container_is_running returns 0 when running" {
    podman() { echo "true"; }
    export -f podman
    run podman_container_is_running "mycontainer"
    [[ "$status" -eq 0 ]]
}

@test "podman_container_is_running returns 1 when stopped" {
    podman() { echo "false"; }
    export -f podman
    run podman_container_is_running "mycontainer"
    [[ "$status" -ne 0 ]]
}

@test "podman_get_container_id outputs container ID" {
    podman() { echo "abc123def456"; }
    export -f podman
    run podman_get_container_id "mycontainer"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "abc123def456" ]]
}

@test "podman_get_container_image outputs image name" {
    podman() { echo "localhost/myimage:1.0.0"; }
    export -f podman
    run podman_get_container_image "mycontainer"
    [[ "$status" -eq 0 ]]
    [[ "$output" == "localhost/myimage:1.0.0" ]]
}
