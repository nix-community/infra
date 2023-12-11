{ pkgs, ... }:
let
  terraform' = pkgs.terraform.overrideAttrs (_: { meta = { }; });
in
{
  devShells = {
    terraform = with pkgs; mkShellNoCC {
      packages = [
        (terraform'.withPlugins (p: [
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
