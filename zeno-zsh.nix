{
  # build dependencies
  lib,
  callPackage,
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
  ghd = callPackage ./scripts/ghd {};
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

  zdotdir = "$out/zdotdir";
in
stdenv.mkDerivation {
  name = "zeno-zsh";
  src = ./src;
  nativeBuildInputs = [
    makeWrapper
    zsh
  ];
  zdotdir = "$out/zdotdir";
  installPhase = ''
    mkdir -p ${zdotdir}
    cat > ${zdotdir}/.zshrc <<EOF

    # Sources a file relative to the src directory
    function load {
      source $src/\$1
    }

    # Cleans up the environment
    function cleanup {
      unfunction load
      unset ZDOTDIR
    }

    ${zshPlugins}

    load init.zsh

    cleanup
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

