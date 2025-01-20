{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    nix.gc.automatic = false;

    boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_6;

    boot.zfs.package = pkgs.zfs_2_3;

    # kernel samepage merging
    hardware.ksm.enable = true;

    systemd.services.free-space = {
      serviceConfig.Type = "oneshot";
      startAt = "hourly";
      path = [
        config.nix.package
        pkgs.coreutils
      ];
      script = builtins.readFile "${inputs.self}/modules/shared/free-space.bash";
    };

    nix.settings.extra-platforms = lib.mkIf (config.nixpkgs.hostPlatform.system == "x86_64-linux") [
      (lib.mkIf (config.boot.binfmt.emulatedSystems == [ ]) "i686-linux")
      "x86_64-v1-linux"
      "x86_64-v2-linux"
      "x86_64-v3-linux"
      (lib.mkIf (builtins.elem "gccarch-x86-64-v4" config.nix.settings.system-features) "x86_64-v4-linux")
    ];

    nix.settings.system-features =
      [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
        "gccarch-${config.nixpkgs.hostPlatform.gcc.arch}"
      ]
      ++ map (x: "gccarch-${x}") (
        lib.systems.architectures.inferiors.${config.nixpkgs.hostPlatform.gcc.arch} or [ ]
      );

    # Bump the open files limit so that non-root users can run NixOS VM tests
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nofile";
        type = "-";
        value = "20480";
      }
    ];
  };
}
