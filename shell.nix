{
  perSystem = { config, pkgs, ... }: {
    devShells = {
      default = with pkgs; mkShellNoCC {
        buildInputs = [
          jq
          sops
          ssh-to-age
          (python3.withPackages (
            p: [
              p.deploykit
              p.invoke
              p.requests
            ]
          ))
          rsync
          config.treefmt.build.wrapper
        ];
      };
    };
  };
}
