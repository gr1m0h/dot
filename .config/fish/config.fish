# remove greeting messsage
set -x fish_greeting

# vi mode
fish_vi_key_bindings

function fish_mode_prompt
end

# prompt
function fish_prompt
  if test "$fish_key_bindings" = "fish_vi_key_bindings"
    switch $fish_bind_mode
      case default
        set_color bd93f9 purple
      case insert
        set_color 50fa7b green
      case replace_one
        set_color ffb86c magenta
      case replace
        set_color ffb86c magenta
      case visual
        set_color f1fa8c yellow
      end
    echo (prompt_pwd) "> "
  end
end

# output git branch
function git_branch
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
end

# right side prompt
function fish_right_prompt
  set_color ff79c6 brred
  echo (git_branch)
end

# util
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

set -gx EDITOR $HOME/.asdf/shims/nvim
set -gx XDG_DATA_HOME $HOME/.local/share

# rm
alias rm='rubbish chuckout'

# asdf
source /opt/homebrew/opt/asdf/libexec/asdf.fish

# aqua
set -gx AQUA_ROOT_DIR $XDG_DATA_HOME/aquaproj-aqua
set -gx PATH $AQUA_ROOT_DIR/bin $PATH

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
