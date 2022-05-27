# Dotpie

My personal dotfiles.

## Prerequisites

- `stow`
- `zsh` for MacOS and Linux, although it may work with bash

## Usage

Use the stow wrapper (`./stoww`), e.g.:

```sh
./stoww n-mac-alacritty h-zsh
```

if you want to pass some args to stow, do it before providing the directories:

```sh
./stoww -n -R h-zsh
```

Dirs starting with `c-` go to the system-specific config directory, so
`%APPDATA%` for Windows, `~/.config` for Linux, and `~/Library/Application
Support` for MacOS.

Dirs starting with `n-` go to `~/.config` for Unix systems.

Dirs starting with `h-` go to home directory.
