{
  description = "terraform devshell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs = { nixpkgs, self }: {
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
      (system: {
        default = with nixpkgs.legacyPackages.${system}; mkShellNoCC {
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
      });
  };
}
