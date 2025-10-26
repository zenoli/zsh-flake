{
  fzf,
  gh,
  git,
  jq,
  writeShellApplication,
}:
writeShellApplication {
  name = "ghd";
  runtimeInputs = [ fzf gh jq git ];
  text = builtins.readFile ./script.sh;
}
