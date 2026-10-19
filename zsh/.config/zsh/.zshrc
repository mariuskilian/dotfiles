# Starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"


# ZSH Add-Ons
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none


# Shift tab to accept auto suggestions
bindkey '^[[Z' 	autosuggest-accept	# tab	  	| autosuggest

# Git aliases
alias gs="git status"
alias gw="git switch"
alias gl="git log"
alias gln="git log --oneline -n"
alias ga="git add"
alias gc="git commit"
alias gca="git commit --amend"
alias gcane="git commit --amend --no-edit"
alias gpush="git push"
alias gp="git pull"
alias gf="git fetch"
alias gitalias="alias | grep 'git'"

# Load the ssh key, then bring every repo under ~/wise up to date concurrently.
# Per repo: fetch --all --prune, park the current branch if it is a side branch
# with no commits for $GITFETCHALL_STALE_DAYS days (commit the worktree, switch
# back to the default branch), fast-forward the default branch (master or main,
# whichever the remote uses), pull in anything a collaborator pushed to the
# current branch, then rebase that branch onto the default branch if that
# applies without conflict. Per-repo logic lives in bin/gitfetchall-repo, which
# buffers its output so parallel runs stay readable.
#
#   gitfetchall              fetch + park stale + fast-forward + sync upstream + rebase
#   gitfetchall --no-park    leave stale side branches checked out
#   gitfetchall --no-rebase  fetch + park + fast-forward only (no upstream sync)
#   gitfetchall --fetch-only fetch only (original behaviour)
#   gitfetchall -j 24        override concurrency ($GITFETCHALL_JOBS, default 12)
#   gitfetchall --stale-days 14   age that counts as stale ($GITFETCHALL_STALE_DAYS, default 28)
#
# A branch that took commits from its own upstream is left off the default
# branch: rebasing it there would rewrite published history and need a
# force-push, which stays a manual decision.
gitfetchall() {
  local mode=rebase park=1 jobs=${GITFETCHALL_JOBS:-12} root=${GITFETCHALL_ROOT:-~/wise}
  local stale=${GITFETCHALL_STALE_DAYS:-28}
  while (( $# )); do
    case $1 in
      --fetch-only|-f) mode=fetch ;;
      --no-rebase)     mode=ff ;;
      --no-park)       park=0 ;;
      --stale-days)    stale=$2; shift ;;
      --jobs|-j)       jobs=$2; shift ;;
      --help|-h)
        print -rl -- "usage: gitfetchall [--fetch-only|--no-rebase] [--no-park] [--stale-days N] [-j N]" \
                     "  default: fetch, park side branches idle ${stale}d+, fast-forward default branch, rebase current branch"
        return 0 ;;
      *) print -u2 -r -- "gitfetchall: unknown option: $1"; return 2 ;;
    esac
    shift
  done

  local -a repos
  repos=($root/*/.git(N/:h))
  if (( ! $#repos )); then
    print -u2 -r -- "gitfetchall: no git repos found in $root"
    return 1
  fi

  local helper=${ZDOTDIR:-$HOME/.config/zsh}/bin/gitfetchall-repo
  if [[ ! -x $helper ]]; then
    print -u2 -r -- "gitfetchall: missing or non-executable helper: $helper"
    return 1
  fi

  gitkey || return

  # Fail fast rather than hang on a credential prompt in a background job.
  local -x GIT_SSH_COMMAND="ssh -o BatchMode=yes" GITFETCHALL_MODE=$mode \
           GITFETCHALL_PARK=$park GITFETCHALL_STALE_DAYS=$stale
  local log=$(mktemp -t gitfetchall)
  print -r -- "$#repos repos, $jobs at a time, mode=$mode, park=$park (${stale}d)"

  # Each repo's output goes to a file of its own, so the finished runs can be
  # replayed in $repos order -- i.e. alphabetically -- instead of in whatever
  # order they happen to complete. $repos is a glob, so it is already sorted,
  # and repo names are unique within $root. Progress dots go to stderr, which
  # is still the terminal, to show life while the block is being buffered.
  local -x GITFETCHALL_OUTDIR=$(mktemp -d -t gitfetchall-out)
  # Ctrl-C part way through 70 fetches is routine, and zsh does not run a
  # function's EXIT trap when a signal unwinds it -- so clean the spool up here
  # as well. Returning non-zero from the handler is what makes the function
  # actually abort instead of carrying on into the report.
  trap 'rm -rf -- "$GITFETCHALL_OUTDIR"; return 130' INT TERM HUP
  print -nu2 -r -- "working "
  print -rN -- $repos | xargs -0 -n1 -P $jobs zsh -c \
    '"$0" "$1" > "$GITFETCHALL_OUTDIR/${1:t}"; s=$?; print -nu2 .; exit $s' "$helper"
  local rc=$pipestatus[2]
  print -u2

  for r in $repos; do
    if [[ -s $GITFETCHALL_OUTDIR/${r:t} ]]; then
      cat "$GITFETCHALL_OUTDIR/${r:t}"
    else
      # Don't let a repo vanish from the report just because its run died.
      print -r -- "✗ $(printf '%-40s' ${r:t}) produced no output"
    fi
  done | tee "$log"
  rm -rf "$GITFETCHALL_OUTDIR"

  # Tally from the per-repo header lines (icon in column 1).
  local ok=$(grep -c '^✓' "$log") skip=$(grep -c '^⚠' "$log") bad=$(grep -c '^✗' "$log")
  # Anchored on the trailing "(was <sha>)" so the "not rebased ..." notes, which
  # also contain the word, don't get counted as work done.
  local ff=$(grep -c ' ff [0-9a-f]' "$log") rb=$(grep -c ' rebased onto .*(was ' "$log")
  local pk=$(grep -c ' parked: ' "$log") ac=$(grep -c ' WIP auto-committed' "$log")
  local sy=$(grep -c ' synced +' "$log")
  print -r -- "---"
  print -r -- "$#repos repos: $ok ok, $skip with notes, $bad failed | $ff fast-forwarded, $rb rebased, $sy synced from upstream, $pk parked ($ac with a WIP commit)"
  (( bad || skip )) && print -r -- "review: grep -E '^(✗|⚠)' $log"
  (( rc == 0 )) || return $rc
  (( bad == 0 ))
}

# Machine-local overrides
[[ -f ~/.zshrc ]] && source ~/.zshrc
