let
  nix-community-infra = pkgs: rec {
    inherit (pkgs)
      git-crypt
      niv
      nixops
      ;

    terraform-provider-vpsadmin =
      pkgs.callPackage ./nix/terraform-provider-vpsadmin.nix {};

    terraform = pkgs.terraform.withPlugins (
      p: [
        p.cloudflare
        terraform-provider-vpsadmin
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

