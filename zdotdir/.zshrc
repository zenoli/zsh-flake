setopt nobeep
echo "Hello from zshrc"


source $ZSH_PLUGINS


eval "$(starship init zsh)"
source <(fzf --zsh)
autoload -U compinit && compinit

# KEYTIMEOUT=1
# VI_MODE_SET_CURSOR=true
# VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
# bindkey -M vicmd '^f' edit-command-line
# bindkey -M viins '^f' edit-command-line

