{ inputs', pkgs, ... }:
{
  devShells = {
    default =
      with pkgs;
      mkShellNoCC {
        packages = [
          inputs'.agenix.packages.default
          jq
          python3.pkgs.deploykit
          python3.pkgs.invoke
          sops
          ssh-to-age
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
