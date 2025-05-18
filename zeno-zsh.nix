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
  pluginSpecs = [
    {
      name = "fzf-tab";
      plugin = zsh-fzf-tab;
      config = "";
    }
    {
      name = "zsh-vi-mode";
      plugin = zsh-vi-mode;
      config = ''
      zvm_after_init_commands+=('source <(fzf --zsh)')
      '';
    }
  ];
  pluginStr = builtins.map 
    (spec: ''
    ##########################
    ## ${spec.name}
    ##########################
    source ${spec.plugin.src}/${spec.name}.plugin.zsh
    zvm_after_init_commands+=('source <(fzf --zsh)')
    '')
    pluginSpecs;
  zshPlugins = writeText "zsh-plugins"
    ''
    ${builtins.concatStringsSep "\n" pluginStr}
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
