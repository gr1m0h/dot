# util
bindkey -v
export WORKSPACE=$HOME/Documents/workspace
setopt no_beep
setopt auto_cd
setopt auto_pushd
autoload -U compinit
compinit

# history
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt share_history
setopt append_history
setopt inc_append_history
setopt hist_no_store
setopt hist_reduce_blanks

# Set PATH, MANPATH, etc., for Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# gpg
export GPG_TTY=$(tty)

# ssh using 1password
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# mise
# eval "$(/opt/homebrew/bin/mise activate zsh)"
export PATH="$HOME/.local/share/mise/shims:$PATH"
export EDITOR="$(mise where neovim)"

# sheldon
eval "$(sheldon source)"

# starship
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
eval "$(starship init zsh)"

# fzf
export FZF_DEFAULT_OPTS=' --color=fg:#f8f8f2,bg:#32324b,hl:#8be9fd --color=fg+:#f8f8f2,bg+:#616175,hl+:#8be9fd --color=info:#8be9fd,prompt:#a8ffde,pointer:#f1fa8c --color=marker:#f1fa8c,spinner:#8be9fd,header:#a8ffde'

# ghq
export GHQ_ROOT_DIR=$WORKSPACE
export GHQ_SELECTOR=fzf

# Instantly recognize newly installed commands
zstyle ":completion:*:commands" rehash 1

# Docker
export DOCKER_HOST="unix://${XDG_CONFIG_HOME}/colima/default/docker.sock"

# flutter
export FLUTTER_ROOT="$(mise where flutter)"
export PATH=$PATH:$HOME/.pub-cache/bin
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# aliases
source $ZDOTDIR/.zsh_aliases

# completions
source $ZDOTDIR/.zsh_completions

# corp settings
# source $ZDOTDIR/.zsh_corp
