{ pkgs, ... }:
{
  devShells = {
    terraform = with pkgs; mkShellNoCC {
      packages = [
        (terraform.withPlugins (p: [
          p.cloudflare
          p.external
          p.hydra
          p.null
          p.sops
          p.tfe
        ]))
      ];
    };
  };
}
