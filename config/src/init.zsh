KEYTIMEOUT=1
# VI_MODE_SET_CURSOR=true
# VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^f' edit-command-line
bindkey -M viins '^f' edit-command-line

load env.zsh
load options.zsh
load history.zsh

