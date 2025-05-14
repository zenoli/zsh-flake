setopt nobeep

# bindkey -v


function load {
    source "$ZDOTDIR/$1"
}

autoload -U compinit; compinit
load plugins/zsh-vi-mode.zsh
load plugins/fzf-tab.zsh

eval "$(starship init zsh)"
source <(fzf --zsh)

# KEYTIMEOUT=1
# VI_MODE_SET_CURSOR=true
# VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
# bindkey -M vicmd '^f' edit-command-line
# bindkey -M viins '^f' edit-command-line

