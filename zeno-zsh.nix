{
  antidote,
  fzf,
  lib,
  makeWrapper,
  starship,
  symlinkJoin,
  zsh,
  zsh-fzf-tab,
  zsh-vi-mode,
}:
symlinkJoin {
  name = "neovim-custom";
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
    wrapProgram $out/bin/zsh \
      --set ZDOTDIR $out/src \
      --set STARSHIP_CONFIG $out/src/starship/pastel-powerline.toml \
      --set SHARE $out/share \
      --prefix PATH : ${
        lib.makeBinPath [
          starship
          fzf
        ]
      }
  '';
}
