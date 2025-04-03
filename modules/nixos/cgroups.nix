{
  inputs,
  pkgs,
  ...
}:
{
  nix = {
    package = pkgs.nixVersions.nix_2_25.overrideAttrs (o: {
      version = o.version + inputs.nix.shortRev;
      src = inputs.nix;
    });

    settings = {
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];

      system-features = pkgs.lib.mkForce [ "uid-range" ];

      auto-allocate-uids = true;
      use-cgroups = true;
    };
  };
}
