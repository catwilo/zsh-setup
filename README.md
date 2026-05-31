# zsh-setup

Canonical zsh environment installer for all platforms (Termux, Debian, macOS).

## Usage

```sh
sh install.sh [--mpd] [--mac] [--dry-run]
```

| Flag        | Description                      |
|-------------|----------------------------------|
| --mpd       | Install MPD audio setup          |
| --mac       | Run macOS-specific bootstrap     |
| --dry-run   | Preview without applying         |

## Clipboard helper

clipc wraps any binary piping stdout+stderr through clipso:

    clipc miko ai miko-task

For compound expressions: { cmd; } |& clipso

## Structure

    dotfiles/.addons-zsh/aliass/shared.zsh   universal aliases + clipc
    dotfiles/.addons-zsh/aliass/termux.zsh   Termux-only
    dotfiles/.addons-zsh/aliass/debian.zsh   Debian-only
    dotfiles/.addons-zsh/aliass/macos.zsh    macOS-only
    install.sh                               idempotent installer
