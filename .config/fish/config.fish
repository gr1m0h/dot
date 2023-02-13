# remove greeting messsage
set -gx fish_greeting

# vi mode
fish_vi_key_bindings

# util
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx WORKSPACE_HOME $HOME/Documents/workspace

# asdf
source /opt/homebrew/opt/asdf/libexec/asdf.fish

# aqua
set -gx AQUA_ROOT_DIR $XDG_DATA_HOME/aquaproj-aqua
set -gx AQUA_GLOBAL_CONFIG $HOME/.aqua.yaml
set -gx PATH $AQUA_ROOT_DIR/bin $PATH

set -gx EDITOR $AQUA_ROOT_DIR/bin/nvim

# prompt
starship init fish | source
set -gx STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml

# fzf
set -Ux FZF_DEFAULT_OPTS "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"


# ghq
set -gx GHQ_ROOT_DIR $WORKSPACE_HOME
set -gx GHQ_SELECTOR fzf

# docker
alias docker-compose='docker-cli-plugin-docker-compose'

# top
alias top='gotop'

# cat
alias cat='bat'

# kubectl
alias k='kubectl'

# go
set -gx GOPATH $HOME/.packages/go
set -gx PATH $GOPATH/bin $PATH

# npm
set -gx NPM_CONFIG_PREFIX $HOME/.packages/npm
set -gx PATH $NPM_CONFIG_PREFIX/bin $PATH

# alias
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

alias wxt='curl https://wttr.in/Tokyo'
