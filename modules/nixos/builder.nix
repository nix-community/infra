{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nix.gc.automatic = false;

  nixpkgs.hostPlatform = {
    inherit (pkgs.hostPlatform) system;
  };

  nix.settings.extra-platforms = lib.mkIf (config.nixpkgs.hostPlatform.system == "x86_64-linux") [
    "i686-linux"
    "x86_64-v1-linux"
    "x86_64-v2-linux"
    "x86_64-v3-linux"
  ];

  nix.settings.system-features = [
    "benchmark"
    "big-parallel"
    "gccarch-${config.nixpkgs.hostPlatform.gcc.arch}"
    "kvm"
    "nixos-test"
  ];

  systemd.services.free-space = {
    serviceConfig.Type = "oneshot";
    startAt = "hourly";
    path = [
      config.nix.package
      pkgs.coreutils
    ];
    script = builtins.readFile "${inputs.self}/modules/shared/free-space.bash";
  };

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
