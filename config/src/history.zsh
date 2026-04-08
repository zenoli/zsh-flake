function() {
    export HISTFILE="$zsh_state_dir/zsh_history"

    setopt extended_history
    setopt hist_ignore_all_dups
    setopt hist_ignore_dups
    setopt hist_save_no_dups
    setopt hist_find_no_dups
    setopt hist_ignore_space
    setopt hist_reduce_blanks
    setopt no_share_history
    setopt inc_append_history
}
