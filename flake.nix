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
      myApp = pkgs.callPackage ./packages/my-app.nix {};
      zenoZsh = pkgs.callPackage ./zeno-zsh.nix {};
    in 
  {
    ## APPS
    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.zenoZsh}/bin/zsh";
    };

    ## PACKAGE
    packages.${system} = {
      default = myApp; 
      inherit zenoZsh;
    };
    ## HOME MANAGER
    homeConfigurations.testuser = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; };
      modules = [
        ./modules/my-app.nix
        ./modules/test-user.nix
      ];
    };
    homeManagerModules.myApp = import ./modules/my-app.nix;
    devShells.${system}.default = import ./dev-shells/shell.nix { inherit pkgs; };
  };
}
