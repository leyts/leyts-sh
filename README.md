# leyts-sh

Reusable Bash library modules for logging and container management.

## Installation

Add as a Git submodule:

```bash
git submodule add https://github.com/leyts/leyts-sh.git
```

## Usage

Source individual modules or use `common.sh` to load everything:

```bash
# Load all modules
source common.sh
```

```bash
# Or load selectively
source logging.sh
```

## Modules

| File | Description |
| --- | --- |
| `assert.sh` | Filesystem guard functions (file/directory existence, permissions) |
| `common.sh` | Convenience loader for all modules |
| `git.sh` | Repository revision and status queries |
| `logging.sh` | Levelled logging (DEBUG/INFO/WARN/ERROR) with colour |
| `podman.sh` | Container and image query/lifecycle helpers |
| `require.sh` | Command availability checks and user prompts |

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `LOG_LEVEL` | `INFO` | Minimum log level: DEBUG, INFO, WARN, ERROR |
| `NO_COLOR` | unset | Set to disable colour |

## Running tests

Requires [bats-core](https://github.com/bats-core/bats-core):

```bash
bats tests/
```

## Linting

```bash
shellcheck lib/*.sh
```
