let
  nix-community-infra = pkgs: rec {
    inherit (pkgs)
      git-crypt
      niv;
    nixopsUnstable = (pkgs.nixopsUnstable.withPlugins(ps: []));

    terraform = pkgs.terraform_0_12.withPlugins (
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
