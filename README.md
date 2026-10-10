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

    install.sh          entrypoint
    lib/                installer modules, sourced in fixed order:
      core.sh           colors, logging, dry-run, guards
      detect.sh         $PLATFORM resolution
      pkg.sh            per-platform package installer
      plugins.sh        zsh plugin fetcher + verifier
      links.sh          atomic copy of dotfiles/ into $HOME
      optional/
        mpd/main.sh     MPD stack (--mpd)
        mac/            macOS bootstrap (--mac): main + deps + nix + path
    dotfiles/           canonical files, copied into $HOME
    packages/           per-platform package lists

## History behavior

- Histfile lives at `~/.local/state/zsh/histfile` (XDG state directory,
  not `$HOME` root).
- `HIST_MAX=2000`. When the file reaches that many lines it is archived
  to `~/.local/state/zsh/history-archive/YYMMDD_HHMM.bak` and reset.
- `preexec()` writes each command to the histfile directly and mirrors
  `HISTORY_IGNORE` by hand: `clipso run /...`, `clipso write ...` and
  `clipso paste` are never recorded.

## Shell autostart: byobu

Every interactive zsh enters byobu (tmux backend) with session name
`s1`. The block lives at the end of `dotfiles/.zshrc` and is guarded:

- interactive shell (`$-` contains `i`)
- real TTY on stdout
- not already inside tmux/byobu (`$TMUX` unset)
- not captured by a wrapper (`CLIPSO_ACTIVE` and `UT_NO_ATTACH` unset)
- not explicitly disabled (`ZSH_NO_BYOBU=1`)
- byobu installed

`byobu new-session -A -s s1` creates the session on first entry and
attaches to it on every subsequent entry, from any shell or any node:
one session reused, not a new one per shell.

Exit is two-step: `Ctrl-d` leaves byobu, `Ctrl-d` again leaves the shell.

### Numbering

`base-index` and `pane-base-index` are set to 1, so the first window is
`w1` and the first pane in it is `1`. The window label in the status bar
is derived from the index (`wN`), never from the running command: labels
stay stable as you switch panes.

The top border of each pane shows `N:command · path` (the pane index, the
program running in it, and its working directory, with `$HOME` shortened
to `~`). The active pane is highlighted (colour214); others are dim.

### Status bar

Only four modules are enabled in `tmux_left` / `tmux_right`:
`session`, `updates_available`, `date`, `time`. Everything else byobu
ships (uptime, load_average, cpu_*, memory, disk, swap, ip_address, ...)
is disabled: it re-reads `/proc` or shells out on every refresh and
brings no signal worth the cost.

### ifconfig shim

`dotfiles/.local/bin/ifconfig` (installed to `~/.local/bin/ifconfig`) is
a wrapper around `$PREFIX/bin/ifconfig`. On Termux without root, toybox
ifconfig cannot read `/proc/net/dev` and prints
`Warning: cannot open /proc/net/dev` on every call; byobu evaluates the
`ip_address` module even when it is disabled in the bar, so the warning
fires at every session start. The shim exits silently when
`/proc/net/dev` is unreadable and execs the real ifconfig otherwise.

## Clipboard helper

`clipc` pipes any command stdout+stderr through `clipso`:

    clipc miko ai miko-task

For compound expressions:

    { cmd; } |& clipso

## Documentation

- `ARCHITECTURE.md` -- modules, install flow, history subsystem, invariants.
