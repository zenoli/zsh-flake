KEYTIMEOUT=1
# VI_MODE_SET_CURSOR=true
# VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^f' edit-command-line
bindkey -M viins '^f' edit-command-line



zsh_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "$zsh_state_dir"

export HISTFILE="$zsh_state_dir/zsh_history"

load options.zsh

