autoload -Uz edit-command-line
zle -N edit-command-line

function zvm_after_init() {
  bindkey -M vicmd '^f' edit-command-line
  bindkey -M viins '^f' edit-command-line
}

load env.zsh
load options.zsh
load history.zsh

