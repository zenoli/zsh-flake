{
  antidote,
  fzf,
  lib,
  writeText,
  makeWrapper,
  starship,
  symlinkJoin,
  zsh,
  zsh-fzf-tab,
  zsh-vi-mode,
  zsh-autopair
}:
let 
  zshPlugins = writeText "zsh-plugins"
    ''
    source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    zvm_after_init_commands+=('source <(fzf --zsh)')
    '';
in
  symlinkJoin {
    name = "zeno-zsh";
    paths = [ 
      zsh 
      zsh-vi-mode 
      zsh-fzf-tab 
    ];
    src = ./src;
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      cp -r $src $out/src
      echo "out dir is $out"
      # cp ${zshPlugins} $out/${zshPlugins.name}
      echo zsh-autopair: ${zsh-autopair} >> $out/tmp.txt
      wrapProgram $out/bin/zsh \
        --set ZDOTDIR $out/src \
        --set STARSHIP_CONFIG $out/src/starship/pastel-powerline.toml \
        --set SHARE $out/share \
        --set ZSH_PLUGINS ${zshPlugins} \
        --prefix PATH : ${
          lib.makeBinPath [
            starship
            fzf
          ]
        }
    '';
  }
