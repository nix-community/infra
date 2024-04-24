{
  imports = [
    ../shared/builder.nix
  ];

  # https://github.com/LnL7/nix-darwin/blob/230a197063de9287128e2c68a7a4b0cd7d0b50a7/modules/nix/default.nix#L201
  nix.daemonProcessType = "Interactive";

  nix.gc.interval = { Minute = 15; };
}
