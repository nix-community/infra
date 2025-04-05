{
  pkgs,
  ...
}:
{
  nix = {
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
