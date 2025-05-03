{ writeShellApplication, cowsay, greeting ? "foo" }:
writeShellApplication {
  name = "my-app";
  runtimeInputs = [ cowsay ];
  text = ''
    cowsay ${greeting}
  '';
}
