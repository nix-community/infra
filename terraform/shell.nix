{ pkgs, ... }:
{
  devShells = {
    terraform =
      with pkgs;
      mkShellNoCC {
        packages = [
          (terraform.withPlugins (p: [
            p.cloudflare
            p.hydra
            p.sops
            p.tfe
          ]))
        ];
      };
  };
}
