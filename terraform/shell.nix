{ pkgs, ... }:
{
  devShells = {
    terraform =
      with pkgs;
      mkShellNoCC {
        packages = [
          (terraform.withPlugins (p: [
            p.cloudflare
            p.github
            p.hydra
            p.sops
            p.tfe
          ]))
        ];
      };
  };
}
