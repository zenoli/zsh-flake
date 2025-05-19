function () {
    source $SHARE/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    zvm_after_init_commands+=('source <(fzf --zsh)')
    # zvm_after_init_commands+=('bindkey -M viins "^R" fzf-history-widget')

    echo "zsh-vi-mode loaded!"
}
