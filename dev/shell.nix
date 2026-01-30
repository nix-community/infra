{ pkgs, ... }:
{
  devShells = {
    default =
      with pkgs;
      mkShellNoCC {
        packages = [
          deploykitEnv
          jq
          sops
          ssh-to-age
          yq-go
        ];
      };
    sotp =
      with pkgs;
      mkShellNoCC {
        packages = [
          sotp
        ];
      };
  };
}
