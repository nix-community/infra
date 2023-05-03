{
  perSystem = { pkgs, ... }: {
    devShells = {
      default = with pkgs; mkShellNoCC {
        packages = [
          jq
          python3.pkgs.deploykit
          python3.pkgs.invoke
          python3.pkgs.requests
          rsync
          sops
          ssh-to-age
        ];
      };
    };
  };
}
