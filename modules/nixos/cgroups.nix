{
  nix = {
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
