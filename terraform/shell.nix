{ inputs', ... }:
let
  tf-pkgs = inputs'.tf-pkgs.legacyPackages;
  terraform' = tf-pkgs.terraform.overrideAttrs (_: { meta = { }; });
in
{
  devShells = {
    terraform = with tf-pkgs; mkShellNoCC {
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
