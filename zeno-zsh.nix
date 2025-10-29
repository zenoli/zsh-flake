{
  # build dependencies
  lib,
  callPackage,
  writeTextFile,
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
  direnv,

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
        zvm_after_init_commands+=('source <(fzf --zsh)')
      '';
    }
  ];
  zshPlugins = lib.concatMapStringsSep "\n" (
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

  zdotdir = writeTextFile {
    name = "zdotdir";
    text = ''
      # Sources a file relative to the src directory
      function load {
        source ${./src}/$1
      }

      # Cleans up the environment
      function cleanup {
        unfunction load
        # unset ZDOTDIR
      }

      ${zshPlugins}

      load init.zsh

      cleanup
    '';
    destination = "/.zshrc";
  };
in
stdenv.mkDerivation {
  name = "zeno-zsh";
  src = ./src;
  nativeBuildInputs = [
    makeWrapper
    zsh
  ];
  installPhase = ''
    makeWrapper ${zsh}/bin/zsh $out/bin/zeno-zsh \
      --set ZDOTDIR ${zdotdir} \
      --prefix PATH : ${
        lib.makeBinPath [
          starship
          fzf
          ghd
          direnv
        ]
      }
  '';
}

