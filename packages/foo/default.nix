{ writeShellApplication, cowsay, lolcat, greeting ? "foo" }:
writeShellApplication {
  name = "foo";
  runtimeInputs = [ cowsay ];
  text = builtins.readFile ./script.sh;
}
