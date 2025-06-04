{
  antidote,
  fzf, lib,
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
  zshInit = writeText "zsh-init"
   ''
   echo "Sourcing zsh-plugins"
   source ${zshPlugins}
   '';
  zdotdir = "$out/zdotdir";
in
  stdenv.mkDerivation {
    name = "zeno-zsh";
    src = ./zdotdir;
    nativeBuildInputs = [ makeWrapper zsh ];
    installPhase = ''
      mkdir -p ${zdotdir}
      cp -r ${./zdotdir}/. ${zdotdir}/
      cp ${zshPlugins} ${zdotdir}/${zshPlugins.name}
      makeWrapper ${zsh}/bin/zsh $out/bin/zsh \
        --set ZDOTDIR ${zdotdir} \
        --prefix PATH : ${
          lib.makeBinPath [
            starship
            fzf
          ]
        }
    '';
  }
