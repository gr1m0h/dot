# fig
# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# theme
export ZSH_THEME='dracula'
source $XDG_CONFIG_HOME/zsh/zsh-syntax-highlighting.sh

# util
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export WORKSPACE=$HOME/Documents/workspace
export EDITOR=/opt/homebrew/bin/nvim

# gpg
export GPG_TTY=$(tty)

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

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

# fig
# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# aliases
source ~/.zsh_aliases
