{ inputs', ... }:
{
  devShells = {
    terraform = with inputs'.tf-pkgs.legacyPackages; mkShellNoCC {
      packages = [
        (terraform.withPlugins (p: [
          p.cloudflare
          p.external
          p.gandi
          p.hydra
          p.null
          p.sops
          p.tfe
        ]))
      ];
    };
  };
}
