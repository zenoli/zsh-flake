zsh_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

if [[ ! -d $zsh_cache_dir ]]; then
  echo "Creating $zsh_cache_dir"
  mkdir -p $zsh_cache_dir
fi

if [[ ! -d $zsh_state_dir ]]; then
  echo "Creating $zsh_state_dir"
  mkdir -p $zsh_state_dir
fi
