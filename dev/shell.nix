{ pkgs, ... }:
{
  devShells = {
    default = with pkgs; mkShellNoCC {
      packages = [
        jq
        python3.pkgs.deploykit
        python3.pkgs.invoke
        rsync
        sops
        ssh-to-age
      ];
    };
    mkdocs = with pkgs; mkShellNoCC {
      packages = [
        python3.pkgs.mkdocs-material
      ];
    };
  };
}
