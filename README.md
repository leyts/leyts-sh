# leyts-sh

![GitHub License](https://img.shields.io/github/license/leyts/homelab)

A small Bash library.

> [!WARNING]
> This library is under development. The API is subject to breaking changes.

## Usage

Load all modules with `common.sh`:

```bash
source lib/common.sh
```

Or load only the modules you need:

```bash
source lib/logging.sh
```

## Modules

| File | Description |
| --- | --- |
| [`assert.sh`](lib/assert.sh) | Filesystem guard functions (file/directory existence and non-existence) |
| [`common.sh`](lib/common.sh) | Convenience loader for all modules |
| [`git.sh`](lib/git.sh) | Repository revision and status queries |
| [`logging.sh`](lib/logging.sh) | Levelled logging (DEBUG/INFO/WARN/ERROR) with console or JSON output |
| [`podman.sh`](lib/podman.sh) | Container and image query/lifecycle helpers |
| [`require.sh`](lib/require.sh) | Command availability checks and user prompts |

## Logging configuration

The `logging.sh` module supports these environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `LOG_LEVEL` | `INFO` | Minimum log level: DEBUG, INFO, WARN, ERROR |
| `LOG_HANDLER` | `console` | Output handler: console, json |
| `NO_COLOR` | unset | Disable colour output |

> [!NOTE]
> `LOG_HANDLER=json` requires [`jq`](https://jqlang.github.io/jq/).

## Running tests

Requires [bats-core](https://bats-core.readthedocs.io/):

```bash
bats tests/
```

## Linting

```bash
shellcheck lib/
```

## Licence

[MIT](LICENCE)
