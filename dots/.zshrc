# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# sheldon
eval "$(sheldon source)"

# util
bindkey -v
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export WORKSPACE=$HOME/Documents/workspace
setopt no_beep
setopt auto_cd
setopt auto_pushd
autoload -U compinit
compinit

# history
HISTFILE=$HOME/.zsh_history
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

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh
export EDITOR="$(asdf where neovim)"

# aqua
export AQUA_ROOT_DIR=$XDG_DATA_HOME/aquaproj-aqua
export AQUA_GLOBAL_CONFIG=$HOME/.aqua.yaml
export PATH=$AQUA_ROOT_DIR/bin:$PATH

# fzf
export FZF_DEFAULT_OPTS=' --color=fg:#f8f8f2,bg:#32324b,hl:#8be9fd --color=fg+:#f8f8f2,bg+:#616175,hl+:#8be9fd --color=info:#8be9fd,prompt:#a8ffde,pointer:#f1fa8c --color=marker:#f1fa8c,spinner:#8be9fd,header:#a8ffde'

# ghq
export GHQ_ROOT_DIR=$WORKSPACE
export GHQ_SELECTOR=fzf

# go
export GOPATH=$HOME/.packages/go
export PATH=$GOPATH/bin:$PATH

# npm
export NPM_CONFIG_PREFIX=$HOME/.packages/npm
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# starship
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
eval "$(starship init zsh)"

# Instantly recognize newly installed commands
zstyle ":completion:*:commands" rehash 1

# aliases
source ~/.zsh_aliases

# flutter
export FLUTTER_ROOT="$(asdf where flutter)"
export PATH=$PATH:$HOME/.pub-cache/bin

# java
. ~/.asdf/plugins/java/set-java-home.zsh

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
