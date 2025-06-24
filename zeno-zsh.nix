{
  # build dependencies
  lib,
  makeWrapper,
  stdenv,
  symlinkJoin,
  writeText,

  # programs
  fzf,
  starship,
  zsh,

  # Zsh Plugins
  zsh-autopair,
  zsh-fzf-tab,
  zsh-vi-mode,
}:
let
  pluginSpecs = [
    {
      name = "fzf-tab";
      plugin = zsh-fzf-tab;
    }
    {
      name = "zsh-vi-mode";
      plugin = zsh-vi-mode;
      config = ''
        zvm_after_init_commands+=('source <(fzf --zsh)')
      '';
    }
  ];
  pluginConfigs =
    builtins.map
      (
        spec:
        builtins.concatStringsSep "\n" (
          [
            ''
              ##########################
              ## ${spec.name}
              ##########################
              source ${spec.plugin.src}/${spec.name}.plugin.zsh
            ''
          ]
          ++ (lib.optionals (builtins.hasAttr "config" spec) [
            "# Config"
            spec.config
          ])
        )
      )
      pluginSpecs;

  zshPlugins = writeText "zsh-plugins" ''
    ${builtins.concatStringsSep "\n" pluginConfigs}
  '';
  zshInit = writeText "zsh-init" ''
    echo "Sourcing zsh-plugins"
    source ${zshPlugins}
  '';
  zdotdir = "$out/zdotdir";
in
stdenv.mkDerivation {
  name = "zeno-zsh";
  src = ./zdotdir;
  nativeBuildInputs = [
    makeWrapper
    zsh
  ];
  installPhase = ''
    mkdir -p ${zdotdir}
    cp -r ${./zdotdir}/. ${zdotdir}/
    # cp ${zshPlugins} ${zdotdir}/${zshPlugins.name}
    makeWrapper ${zsh}/bin/zsh $out/bin/zsh \
      --set ZDOTDIR ${zdotdir} \
      --set ZSH_PLUGIN_CONFIG ${zshPlugins} \
      --prefix PATH : ${
        lib.makeBinPath [
          starship
          fzf
        ]
      }
  '';
}
