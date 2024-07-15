{
  # https://github.com/NixOS/nix/issues/7273
  nix.settings.auto-optimise-store = false;

  nix.optimise.interval = [
    {
      Hour = 5;
      Minute = 45;
    }
  ];
}
