# remove greeting messsage
set -x fish_greeting

# vi mode
fish_vi_key_bindings

# enable grimoh/fish-prompt
function fish_mode_prompt
end

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias rm='rubbish chuckout'

set -gx XDG_DATA_HOME $HOME/.local/share

# asdf
source /opt/homebrew/opt/asdf/libexec/asdf.fish

# aqua
set -gx AQUA_ROOT_DIR $XDG_DATA_HOME/aquaproj-aqua
set -gx PATH $AQUA_ROOT_DIR/bin $PATH

set -gx EDITOR $AQUA_ROOT_DIR/bin/nvim

# kubectl
alias k='kubectl'

# go
set -gx GOPATH $HOME/.packages/go
set PATH $GOPATH/bin $PATH

# npm
set -gx NPM_CONFIG_PREFIX $HOME/.packages/npm
set PATH $NPM_CONFIG_PREFIX/bin $PATH

# mysql
set -gx DATADIR $HOME/.data/mysql
# To initialize a new database
#       mysqld --initialize-insecure --datadir=$DATADIR
#       mysql_ssl_rsa_setup --datadir=$DATADIR
# To run the server:
#       mysqld_safe --datadir=$DATADIR
# To stop the server:
#       mysqladmin -u root shutdown
