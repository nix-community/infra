{ perSystem, pkgs, ... }:

with pkgs;

mkShellNoCC {
  inputsFrom = [ perSystem.self.docs ];
}
