{ pkgs, ... }:
{
  devShells = {
    default =
      with pkgs;
      mkShellNoCC {
        packages = [
          deploykitEnv
          jq
          nixbot-cli
          sops
          ssh-to-age
          yq-go
        ];
      };
  };
}
