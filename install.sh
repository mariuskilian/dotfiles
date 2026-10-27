#!/usr/bin/env bash
# Set up a Mac from this repo, or bring one back in line with it after a pull.
# Safe to re-run: each step skips whatever is already done.
#
#   ./install.sh               brew, stow, extras
#   ./install.sh stow          only the named step(s)
#
#   brew    install Homebrew if it's missing, then everything in Brewfile
#   stow    link the packages in PACKAGES into ~; anything already in the way
#           is moved to ~/.dotfiles-backup/<timestamp>/ first
#   extras  the gh stack extension
set -euo pipefail

DOTFILES=$(cd -P -- "$(dirname -- "$0")" && pwd)

# Packages to link, i.e. configs for tools that are actually installed. ghostty/
# is here because cmux reads its config. nvim/ and tmux/ are kept but unlinked.
PACKAGES=(zsh starship git cmux ghostty vim)

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# Put Homebrew on PATH for this script. A fresh install isn't on it yet; new
# shells get it from zsh/.config/zsh/.zprofile.
load_brew() {
  command -v brew >/dev/null && return
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $b ]] && { eval "$("$b" shellenv)"; return; }
  done
  return 1
}

step_brew() {
  say "Homebrew"
  if ! load_brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew || die "Homebrew installed, but brew isn't where expected"
  fi
  # Upgrades are left to `brew upgrade`, so a re-run only installs what's missing.
  brew bundle install --no-upgrade --file="$DOTFILES/Brewfile"
}

# Move aside whatever stow would refuse to replace on the way to each of a
# package's targets: a real file, or a link (to a file or a whole directory)
# that leads somewhere other than this repo.
move_conflicts() {
  local pkg=$1 src path part parts
  while IFS= read -r -d '' src; do
    path=$HOME
    IFS=/ read -ra parts <<< "${src#"$pkg"/}"
    for part in "${parts[@]}"; do
      path=$path/$part
      [[ -e $path || -L $path ]] || break
      # Resolves into the repo: a link stow made, or a repo file reached through
      # a directory link stow made. Either way it's already ours.
      [[ $(readlink -f -- "$path" 2>/dev/null) == "$DOTFILES"/* ]] && break
      # A real directory: stow links inside it, so keep looking further down.
      [[ -d $path && ! -L $path ]] && continue
      local rel=${path#"$HOME"/}
      mkdir -p -- "$(dirname -- "$backup/$rel")"
      mv -- "$path" "$backup/$rel"
      echo "  moved ~/$rel aside"
      break
    done
  done < <(find "$pkg" \( -type f -o -type l \) -print0)
}

step_stow() {
  say "Stow"
  load_brew || true
  command -v stow >/dev/null || die "stow isn't installed; run ./install.sh brew first"
  # move_conflicts relies on it to recognise files that are already linked.
  readlink -f / >/dev/null 2>&1 || die "needs readlink -f (macOS 12.3 or later)"

  backup=$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)
  # If ~/.config doesn't exist, stow links the whole directory into the first
  # package that has one, and apps then write their config into this repo.
  mkdir -p "$HOME/.config"

  cd "$DOTFILES"
  local pkg
  for pkg in "${PACKAGES[@]}"; do [[ -d $pkg ]] || die "no such package: $pkg"; done
  for pkg in "${PACKAGES[@]}"; do move_conflicts "$pkg"; done
  # Not --restow: unstowing first can fold a real directory such as ~/.config/git
  # into one link to the repo. Plain stow leaves existing links as they are.
  stow --target="$HOME" "${PACKAGES[@]}"
  echo "  linked: ${PACKAGES[*]}"
  [[ -d $backup ]] && warn "files that were in the way are in $backup"
  return 0
}

step_extras() {
  say "Extras"
  load_brew || true

  # Used by the starship prompt (starship/.config/starship/gh-prompt).
  if gh extension list 2>/dev/null | grep -q 'github/gh-stack'; then
    echo "  gh stack already installed"
  elif gh auth status >/dev/null 2>&1; then
    gh extension install github/gh-stack
  else
    warn "skipped gh stack: run 'gh auth login', then 'gh extension install github/gh-stack'"
  fi
}

[[ $(uname -s) == Darwin ]] || die "macOS only"

steps=("$@")
(( $# )) || steps=(brew stow extras)
for step in "${steps[@]}"; do
  case $step in
    brew|stow|extras) "step_$step" ;;
    *) die "unknown step: $step (expected brew, stow or extras)" ;;
  esac
done

say "Done. Open a new terminal to pick up the shell config."
