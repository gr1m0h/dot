# remove greeting messsage
set -gx fish_greeting

# vi mode
fish_vi_key_bindings

# enable grimoh/fish-prompt
function fish_mode_prompt
end

# util
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CONFIG_HOME $HOME/.config

# asdf
source /opt/homebrew/opt/asdf/libexec/asdf.fish

# aqua
set -gx AQUA_ROOT_DIR $XDG_DATA_HOME/aquaproj-aqua
set -gx AQUA_GLOBAL_CONFIG $HOME/.aqua.yaml
set -gx PATH $AQUA_ROOT_DIR/bin $PATH

set -gx EDITOR $AQUA_ROOT_DIR/bin/nvim

# docker
alias docker-compose='docker-cli-plugin-docker-compose'

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

# mysql
set -gx DATADIR $HOME/.data/mysql
# To initialize a new database
#       mysqld --initialize-insecure --datadir=$DATADIR
#       mysql_ssl_rsa_setup --datadir=$DATADIR
# To run the server:
#       mysqld_safe --datadir=$DATADIR
# To stop the server:
#       mysqladmin -u root shutdown
