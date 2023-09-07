{
  imports = [
    ../shared/builder.nix
  ];

  nix.gc.interval = { Minute = 15; };
}
