{ pkgs, ... }:
{
  nix = {
    package = pkgs.nix.overrideAttrs (o: {
      patches = (o.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          # https://github.com/NixOS/nix/pull/13135
          url = "https://github.com/NixOS/nix/commit/7030d2e44fccc6c0fc5f5bc87eb05d7134744131.patch";
          hash = "sha256-rsLP4OiSwQAWPO6CAehzpgnDKoPPDshzXVikUQWEmxU=";
        })
      ];
    });

    settings = {
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];

      system-features = [ "uid-range" ];

      auto-allocate-uids = true;
      use-cgroups = true;
    };
  };
}
