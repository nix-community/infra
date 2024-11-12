{ perSystem, pkgs, ... }:

with pkgs;

mkShellNoCC {
  packages = [
    perSystem.agenix.default
    jq
    python3.pkgs.deploykit
    python3.pkgs.invoke
    sops
    ssh-to-age
  ];
}
