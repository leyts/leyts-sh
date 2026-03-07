# leyts-sh

A Bash library for logging and container management.

> [!WARNING]
> This library is under development. The API is subject to breaking changes.

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
| `assert.sh` | Filesystem guard functions (file/directory existence) |
| `common.sh` | Convenience loader for all modules |
| `git.sh` | Repository revision and status queries |
| `logging.sh` | Levelled logging (DEBUG/INFO/WARN/ERROR) with colour |
| `podman.sh` | Container and image query/lifecycle helpers |
| `require.sh` | Command availability checks and user prompts |

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `LOG_LEVEL` | `INFO` | Minimum log level: DEBUG, INFO, WARN, ERROR |
| `LOG_HANDLER` | `console` | Output handler: console, json |
| `NO_COLOR` | unset | Set to disable colour |

## Running tests

Requires [bats-core](https://bats-core.readthedocs.io/):

```bash
bats tests/
```

## Linting

```bash
shellcheck lib/*.sh
```

## Licence

[MIT](LICENCE)
