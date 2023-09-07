{
  imports = [
    ../shared/builder.nix
  ];

  nix.gc.dates = "hourly";
}
