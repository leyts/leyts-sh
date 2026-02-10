#!/usr/bin/env bash
# common.sh — Convenience loader for all library modules.
#
# Usage:
#   source common.sh
#
# Sources all lib modules. For selective loading, source individual files instead.
#

_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$_COMMON_DIR/assert.sh"
source "$_COMMON_DIR/git.sh"
source "$_COMMON_DIR/logging.sh"
source "$_COMMON_DIR/podman.sh"
source "$_COMMON_DIR/require.sh"
