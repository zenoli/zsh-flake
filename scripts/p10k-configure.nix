{
  lib,
  zsh,
  mktemp,
  zsh-powerlevel10k,
  writeScriptBin,
}:
writeScriptBin "p10k-configure" ''
  #!/usr/bin/env -S ${lib.getExe zsh} -i
  ZDOTDIR=$(${lib.getExe mktemp} -d --tmpdir zdotdir-XXXXXXXXXX)
  export ZDOTDIR
  source ${zsh-powerlevel10k.src}/powerlevel10k.zsh-theme
  p10k configure
  read "move?Move $ZDOTDIR/.p10k.zsh? [y/n] "
  if [[ $move == y ]]; then
    dest=.
    vared -p "Destination directory: " dest
    mv "$ZDOTDIR/.p10k.zsh" "$dest/.p10k.zsh"
    echo "Moved to $dest/.p10k.zsh"
    rm -rf "$ZDOTDIR"
    echo "Removed $ZDOTDIR"
  else
    echo ".p10k.zsh was created at:"
    echo "$ZDOTDIR/.p10k.zsh"
  fi
  echo Done!
''
