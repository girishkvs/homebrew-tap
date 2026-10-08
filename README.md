# Homebrew tap

Homebrew packaging for [MCP Pacemaker](https://github.com/girishkvs/mcp-pacemaker), a local MCP process supervisor and transport bridge.

## Install

```sh
brew tap girishkvs/tap
brew install girishkvs/tap/mcp-pacemaker
mcp-pacemaker --version
```

This formula installs **2.0.2** from the checksum-pinned npm archive, using Homebrew `node@24` and the original dependency lock from source commit [`a9fd5be23a50d4f3e3b787b678a8e85bdfb45fa2`](https://github.com/girishkvs/mcp-pacemaker/tree/a9fd5be23a50d4f3e3b787b678a8e85bdfb45fa2). Dependencies are installed with `npm ci`; Homebrew's cooldown and script restrictions are retained.

Installation adds `mcp-pacemaker` and `mcp-bridge`. It does **not** run setup or create a `brew services` job.

## Tested scope and limits

Validated on **macOS 15.7.9 ARM64, Homebrew 6.0.22**: formula syntax/style/audit, installation, all 48 locked production dependency versions, CLI help, `brew test`, an installed MCP round trip, and package removal without prior configuration.

Configured launchd setup/teardown, physical reboot/login, product upgrades, Node upgrades and Cellar cleanup are **not yet validated** for this tap. Intel macOS and Linux are not qualified.

Process-leak and safe-upgrade fixes are in progress and are **not included in 2.0.2**. Do not assume a running setup can be upgraded safely or is crash-safe across abrupt shutdown or power loss.

## Explicit setup

Back up your host configuration and review the [2.0.2 setup guide](https://github.com/girishkvs/mcp-pacemaker/blob/a9fd5be23a50d4f3e3b787b678a8e85bdfb45fa2/README.md) before opting in:

```sh
mcp-pacemaker init
```

Setup can change host MCP settings, import server definitions and register OS auto-start. It is separate from Homebrew installation.

## Remove

If you configured Pacemaker, review the [2.0.2 removal notes](https://github.com/girishkvs/mcp-pacemaker/blob/a9fd5be23a50d4f3e3b787b678a8e85bdfb45fa2/README.md#uninstall) and run teardown with the installed CLI **before** removing the package:

```sh
mcp-pacemaker uninstall
brew uninstall girishkvs/tap/mcp-pacemaker
```

For an unconfigured install, only the `brew uninstall` command is needed.

Product teardown affects managed bridges beyond a single port. It restores whole available host-file backups, so later edits can be lost. On macOS it unloads auto-start, but the launchd plist can remain. Files without backups and native Claude Code registrations remain unchanged. Do not use teardown for a routine package upgrade. Data under `~/.mcp-pacemaker` is user data, not package payload.

## License

[MIT](LICENSE).
