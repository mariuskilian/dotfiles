# Homebrew: /opt/homebrew on Apple Silicon, /usr/local on Intel
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $brew ]] && { eval "$($brew shellenv)"; break }
done
unset brew

# Machine-local profile overrides
[[ -f ~/.zprofile ]] && source ~/.zprofile
