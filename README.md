## Prerequisites

`stow`

## Usage

First, source the `.conf/*` file, applicable to the system.

e.g.:
```sh
source .conf/mac.sh
```

Then, stow the desired directories with option `-t $CONFDIR`, e.g.:
```sh
stow -t $CONFDIR c-vscode
```

Dirs starting with `c-` go to the system-specific config directory, so
`%APPDATA%` for Windows, `~/.config` for Linux, and `~/Library/Application
Support` for MacOS.
```sh
source .conf/mac.sh
stow -t $CONFDIR c-vscode
```

Dirs starting with `n-` go to `~/.config` for Unix systems
and `%APPDATA%` for Windows.
```sh
source .conf/nix.sh
stow -t $CONFDIR n-nvim
```

Dirs starting with `h-` go to home directory.
```sh
stow -t $HOME h-ideavim
```
