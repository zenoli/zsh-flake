{
  description = "A flake providing my zsh config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in 
  {
    packages.${system}.default = pkgs.writeShellApplication {
      name = "my-app";
      runtimeInputs = [ pkgs.cowsay ];
      text = ''
        cowsay foo
      '';
    };
  };
}
