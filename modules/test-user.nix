{
  home = {
    username = "testuser";
    homeDirectory = "/home/testuser";
    stateVersion = "24.11";
  };
  programs.myApp = {
    enable = true;
    greeting = "Bar";
  };
}
