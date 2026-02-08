{ pkgs, self' }:
{
  inherit pkgs; 
  direnv = {
    enable = true;
    package = self'.packages.direnv;
  };
  fzf = {
    enable = true;
  };
}
