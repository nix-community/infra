{ pkgs, ... }:
{
  devShells = {
    default =
      with pkgs;
      mkShellNoCC {
        packages = [
          jq
          json-sort
          python3.pkgs.deploykit
          python3.pkgs.invoke
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
