# util
bindkey -v
source $ZDOTDIR/.zshenv
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

# gpg
export GPG_TTY=$(tty)

# mise
eval "$(/opt/homebrew/bin/mise activate zsh)"
export EDITOR="$(mise where neovim)"

# ghq
export GHQ_ROOT_DIR=$WORKSPACE
export GHQ_SELECTOR=fzf

# starship
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
eval "$(starship init zsh)"

# sheldon
eval "$(sheldon source)"

# fzf
export FZF_DEFAULT_OPTS=' --color=fg:#f8f8f2,bg:#32324b,hl:#8be9fd --color=fg+:#f8f8f2,bg+:#616175,hl+:#8be9fd --color=info:#8be9fd,prompt:#a8ffde,pointer:#f1fa8c --color=marker:#f1fa8c,spinner:#8be9fd,header:#a8ffde'

# flutter
export FLUTTER_ROOT="$(mise where flutter)"
export PATH=$PATH:$HOME/.pub-cache/bin
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# go
export GOPATH=$HOME/.packages/go
export PATH=$GOPATH/bin:$PATH

# npm
export NPM_CONFIG_PREFIX=$HOME/.packages/npm
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# aqua
export AQUA_ROOT_DIR=$XDG_DATA_HOME/aquaproj-aqua
export AQUA_GLOBAL_CONFIG=$HOME/.aqua.yaml
export PATH=$AQUA_ROOT_DIR/bin:$PATH

# Instantly recognize newly installed commands
zstyle ":completion:*:commands" rehash 1

# aliases
source $ZDOTDIR/.zsh_aliases

# completions
source $ZDOTDIR/.zsh_completions
