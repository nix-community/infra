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
  };
}
