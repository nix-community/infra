{
  imports = [ ../shared/builder.nix ];

  nix.gc.dates = "hourly";

  # Bump the open files limit so that non-root users can run NixOS VM tests
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "20480";
    }
  ];
}
