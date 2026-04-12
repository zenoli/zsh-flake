# Enable Powerlevel10k instant prompt. Should stay close to the top of ./demo-zdotdir/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ./demo-zdotdir/.p10k.zsh.
[[ ! -f ./demo-zdotdir/.p10k.zsh ]] || source ./demo-zdotdir/.p10k.zsh
