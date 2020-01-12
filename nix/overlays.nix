let
  nix-community-infra = pkgs: rec {
    inherit (pkgs)
      git-crypt
      niv
      nixops
      ;

    actions-runner = pkgs.callPackage ./actions-runner { };

    terraform = pkgs.terraform.withPlugins (
      p: [
        p.cloudflare
        p.null
        p.external
      ]
    );
  };

in
[
  (self: super: { sources = import ./sources.nix; })
  (self: super: {
    nix-community-infra = nix-community-infra super;
  })
]
