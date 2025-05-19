{
  antidote,
  fzf,
  lib,
  writeText,
  makeWrapper,
  starship,
  stdenv,
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
  stdenv.mkDerivation {
    name = "zeno-zsh";
    src = ./zdotdir;
    nativeBuildInputs = [ makeWrapper zsh ];
    postBuild = ''
      mkdir $out
      cp -r $src $out/zdotdir
      makeWrapper ${zsh}/bin/zsh $out/bin/zsh \
        --set ZDOTDIR $out/zdotdir \
        --set ZSH_PLUGINS ${zshPlugins} \
        --prefix PATH : ${
          lib.makeBinPath [
            starship
            fzf
          ]
        }
    '';
  }
