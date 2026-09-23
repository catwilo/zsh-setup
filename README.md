# zsh-setup

Canonical zsh environment installer for the unix-toolkit-tools ecosystem.
One config tree serves Termux, Debian and macOS.

## Install

    sh install.sh [--mpd] [--mac] [--dry-run]

| Flag | Effect |
|------|--------|
| --mpd | Install the optional MPD audio stack |
| --mac | Run the macOS-specific bootstrap |
| --dry-run | Print the actions without executing |

Idempotent: re-running converges to the current source tree.

## Structure

    dotfiles/           canonical dotfiles, copied to $HOME on install
    lib/                installer primitives (core, detect, pkg, plugins, links)
    packages/           per-platform package lists
    optional/           opt-in extras (mpd, mac bootstrap)
    configs/            legacy, kept empty
    install.sh          entrypoint

## History behavior

- Histfile lives at `~/.local/state/zsh/histfile` (XDG state directory,
  not `$HOME` root).
- `HIST_MAX=2000`. When the file reaches that many lines it is archived
  to `~/.local/state/zsh/history-archive/YYMMDD_HHMM.bak` and reset.
- `preexec()` writes each command to the histfile directly and mirrors
  `HISTORY_IGNORE` by hand: `clipso run /...`, `clipso write ...` and
  `clipso paste` are never recorded.

## Clipboard helper

`clipc` pipes any command stdout+stderr through `clipso`:

    clipc miko ai miko-task

For compound expressions:

    { cmd; } |& clipso

## Documentation

- `ARCHITECTURE.md` -- modules, install flow, history subsystem, invariants.
