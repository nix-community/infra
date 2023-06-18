{
  imports = [
    ../shared/nix-remote-builder.nix
  ];

  nix.gc.dates = "*:45";

  # Randomize GC to avoid thundering herd effects.
  nix.gc.randomizedDelaySec = "1800";

  # Allow more open files for non-root users to run NixOS VM tests.
  security.pam.loginLimits = [
    { domain = "*"; item = "nofile"; type = "-"; value = "20480"; }
  ];

  users.users.nix-remote-builder.isNormalUser = true;
  users.users.nix-remote-builder.group = "nogroup";
}
