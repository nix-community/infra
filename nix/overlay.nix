let
  nix-community-infra = pkgs: {
    inherit (pkgs)
      git-crypt
      niv
      nixops
      ;

    terraform = pkgs.terraform.withPlugins (
      p: [
        p.cloudflare
      ]
    );
  };

  overlay = self: super: {
    sources = import ./sources.nix;
    nix-community-infra = nix-community-infra super;
  };
in
  overlay
