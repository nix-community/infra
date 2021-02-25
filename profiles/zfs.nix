{...}: {
  services.zfs = {
    autoSnapshot.enable = true;
    # defaults to 12, which is a bit much given how much data is written
    autoSnapshot.monthly = 1;
    autoScrub.enable = true;
  };
}
