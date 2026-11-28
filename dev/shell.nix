{ pkgs, ... }:
{
  devShells = {
    default =
      with pkgs;
      mkShellNoCC {
        packages = [
          age
          deploykitEnv
          jq
          sops
          yq-go
        ];
      };
  };
}
