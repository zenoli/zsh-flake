{
  # build dependencies
  lib,
  writeShellApplication,
  makeWrapper,
  stdenv,
  symlinkJoin,
  writeText,

  # programs
  fzf,
  gh,
  git,
  jq,
  starship,
  zsh,

  # Zsh Plugins
  zsh-autopair,
  zsh-fzf-tab,
  zsh-vi-mode,
}:
let
  ghd = writeShellApplication {
    name = "ghd";
    runtimeInputs = [ fzf gh jq git ];
    text = builtins.readFile ./scripts/ghd.sh;
  };
  pluginSpecs = [
    {
      name = "fzf-tab";
      plugin = zsh-fzf-tab;
    }
    rec {
      name = "zsh-vi-mode";
      plugin = zsh-vi-mode;
      config = ''
        # source ${zdotdir}/plugins/${name}.zsh
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

  zshPlugins = ''
    ${builtins.concatStringsSep "\n" pluginConfigs}
  '';
  # zshRc = writeText ".zshrc" ''
  #   source ${zshPlugins}
  #   source $ZDOTDIR/init.zsh
  #   echo "Sourcing zsh-plugins"
  # '';
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
    cat > ${zdotdir}/.zshrc <<EOF
    ${zshPlugins}
    source ${zdotdir}/init.zsh
    EOF
    makeWrapper ${zsh}/bin/zsh $out/bin/zeno-zsh \
      --set ZDOTDIR ${zdotdir} \
      --prefix PATH : ${
        lib.makeBinPath [
          starship
          fzf
          ghd
        ]
      }
  '';
}

