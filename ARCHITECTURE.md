# Architecture -- zsh-setup

Single source of truth for the zsh environment on Termux, Debian and
macOS. The repo is authoritative; `$HOME` is a deployment target.

## Principle

`lib/links.sh` copies the versioned files into `$HOME` on every install.
Symlinks are intentionally avoided: the ecosystem standard (`ai.md`,
DOTFILES) requires `cp -RfL`, because a symlinked `.zshrc` breaks under
atomic-copy installers and cross-node sync.

## Layers

    install.sh                       entrypoint; parses --mpd/--mac/--dry-run
    lib/                             sourced by install.sh in this order:
      core.sh                        colors, logging, dry-run, guards
      detect.sh                      PLATFORM resolution
      pkg.sh                         per-platform package installer
      plugins.sh                     zsh plugin fetcher + verifier
      links.sh                       atomic copy of dotfiles/ into $HOME
      optional/                      opt-in extras, sourced only when asked
        mpd/main.sh                  MPD + ncmpcpp setup (--mpd)
        mac/main.sh                  macOS bootstrap (--mac)
        mac/deps.sh                  Homebrew / system deps
        mac/nix.sh                   Nix install / repair helpers
        mac/path.sh                  PATH wiring for non-interactive shells
        mac/repair-nix.sh            one-shot repair script
        mac/versions.env             pinned package versions
    dotfiles/                        canonical files, copied into $HOME
      .zshrc .zshenv .zprofile       shell baseline
      .gitconfig .vimrc .prettierrc  tool baselines
      .addons-zsh/aliass/            aliases + functions, sourced by .zshrc
        shared.zsh                   universal aliases + clipc
        functions.zsh                preexec, hist_rotate, alia, py, wpy, pvi
        clipso.zsh                   Alt+G wrapper, zshaddhistory filter
        main.zsh                     legacy aliases + bindkeys (standalone)
        termux.zsh debian.zsh macos.zsh pc.zsh    platform deltas
      .config/                       ranger, byobu, starship, alacritty, i3, ...
      .termux/                       Termux terminal properties
    packages/<platform>.env          package lists

## Install flow

1. Parse `--mpd`, `--mac`, `--dry-run`.
2. Source the five `lib/` modules (order is fixed, see above).
3. Refuse to run without `bash` in `PATH` -- every ecosystem tool
   declares `#!/usr/bin/env bash`.
4. `pkg_install_file packages/<platform>.env`.
5. `install_plugins` -- clones/updates zsh plugins under `.addons-zsh/`.
6. `link_dotfiles` -- atomic copy per file into `$HOME`.
7. `_set_default_shell` -- reads `~/.termux/shell` on Termux, `$SHELL`
   elsewhere. On Termux `$SHELL` reflects the running process, not what
   a new session will launch, so it is not authoritative there.
8. `--mpd` and `--mac` steps (mutually independent, both optional).
9. `verify_plugins`.

## History subsystem

- `HISTFILE=~/.local/state/zsh/histfile`. The XDG state directory keeps
  rotated archives out of `$HOME` root.
- `HIST_MAX=2000`. `HISTSIZE` and `SAVEHIST` mirror it.
- `hist_rotate()` (in `functions.zsh`) runs when the file reaches the
  threshold: it moves the file to
  `${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history-archive/YYMMDD_HHMM.bak`
  and reopens an empty histfile.
- `preexec()` writes each command to `$HISTFILE` directly. This
  bypasses zsh native history engine, so `HISTORY_IGNORE` and
  `zshaddhistory` hooks do not fire on that write. `preexec()` mirrors
  the ignore patterns itself:

        [[ "$1" == "clipso run /"*   ]] && { hist_rotate; return; }
        [[ "$1" == "clipso write "*  ]] && { hist_rotate; return; }
        [[ "$1" == "clipso paste"    ]] && { hist_rotate; return; }

  `clipso run /` is the only correct pattern for the Alt+G wrapper,
  which writes a temp file at `${TMPDIR}/clipso-cmd.XXXXXX` and
  re-enters the line as `clipso run <path>`. A user typing
  `clipso run <path>` by hand is treated the same way; that is the
  intended behavior.

## Dotfiles copy strategy

`link_dotfiles()` (in `lib/links.sh`) stages each file in
`<dstdir>/.link-tmp.XXXXXX/<name>` and then `mv -f` over the
destination. Stage-then-mv guarantees a process kill between writes
never leaves the destination missing. Copying (`cp -RfL`), not
symlinking, is required by the ecosystem standard.

## byobu autostart

The block at the end of `dotfiles/.zshrc` runs once per interactive
shell. Guards, in order:

    [[ $- == *i* ]]                            interactive shell
    [ -t 1 ]                                   real TTY on stdout
    [ -z "${TMUX:-}" ]                         not already inside tmux
    [ -z "${CLIPSO_ACTIVE:-}" ]                not captured by a wrapper
    [ -z "${UT_NO_ATTACH:-}" ]                 not captured by a wrapper
    [ -z "${ZSH_NO_BYOBU:-}" ]                 explicit escape hatch
    command -v byobu >/dev/null 2>&1           byobu installed

Then: `byobu new-session -A -s main`.

`CLIPSO_ACTIVE` and `UT_NO_ATTACH` are the generic capture contract:
any wrapper that captures stdout (clipso, a test harness, a script)
sets one of them to declare that interactive side-effects must not run.
The names are not clipso-specific; `ut` itself sets `UT_NO_ATTACH` in
the same way for its own nested calls.

## Invariants

- **Copy, never symlink** under `dotfiles/`.
- **`HISTFILE` always under `~/.local/state/zsh/`.** Placing it in
  `$HOME` root is what littered the home with `.bak` archives before
  the fix.
- **`HISTORY_IGNORE` patterns are duplicated in `preexec()`.** Adding
  a wrapper that must not be recorded requires editing both places.
- **`$SHELL` is not authoritative on Termux.** Always check
  `~/.termux/shell` on Termux.
- **`lib/` modules are sourced by `install.sh` only**, in the fixed
  order core, detect, pkg, plugins, links. A module that needs
  `core.sh` must source it or declare it as a dependency.
- **`lib/optional/` modules are sourced by `install.sh` only when the
  corresponding flag is passed.** They receive `$SETUP_DIR` and the
  core helpers (`ok`, `info`, `err`, `run`, `step`, `warn`) already in
  scope.
- **`byobu new-session -A -s main` is idempotent.** One session named
  `main` across the whole fleet; entering from any shell or node
  attaches to the same one.

## Platform matrix

| Platform | Detection | Deltas |
|---|---|---|
| Termux | `$TERMUX_VERSION` or `/data/data/com.termux` | `.termux/`, byobu, mpd, ncmpcpp, starship |
| Debian | `/etc/debian_version` | `.xinitrc`, alacritty, deadd, i3, i3status |
| macOS | `uname` = `Darwin` | alacritty; `--mac` runs the Nix/deps bootstrap |
| unknown | fallback | shared dotfiles only |
