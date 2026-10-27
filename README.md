# Dotfiles

## Installation

```sh
git clone https://github.com/mariuskilian/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` is safe to re-run, e.g. after a `git pull`. It:

1. installs Homebrew if needed, then everything in `Brewfile`
2. stows the packages listed in `PACKAGES` at the top of `install.sh` into `~`, moving anything already in the way to `~/.dotfiles-backup/<timestamp>/`
3. installs the `gh stack` extension (needs `gh auth login` first)

Run only some steps with e.g. `./install.sh stow` (steps: `brew`, `stow`, `extras`).

To stow a single package by hand: `stow <package>` from this directory.

## Adding things

- **A tool:** add it to `Brewfile`. `brew bundle cleanup --file=~/.dotfiles/Brewfile` lists what's installed but missing from it.
- **A config:** create a top-level directory that mirrors the paths under `~`, e.g. `foo/.config/foo/config`, and add it to `PACKAGES` in `install.sh`.
- **Machine-specific shell config:** put it in `~/.zshrc` or `~/.zprofile`, not here. The shared config sources them last.
