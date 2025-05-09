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
    in 
  {
    ## PACKAGE
    packages.${system}.default = myApp; 
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
