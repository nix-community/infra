{
  config,
  lib,
  pkgs,
  ...
}:
# https://github.com/NixOS/aarch64-build-box/pull/133
{
  config =
    lib.mkIf
      (
        lib.hasPrefix "build" config.networking.hostName
        && pkgs.stdenv.hostPlatform.system == "aarch64-linux"
      )
      {
        boot.kernelParams = [ "compat_uts_machine=armv7l" ];

        boot.kernelPatches = [
          # https://lists.ubuntu.com/archives/kernel-team/2016-January/068203.html
          # https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/jammy/patch/?id=c1da50fa6eddad313360249cadcd4905ac9f82ea
          {
            name = "compat_uts_machine";
            patch = ./compat_uts_machine.patch;
          }
        ];

        nix.settings.extra-platforms = [ "armv7l-linux" ];
        nix.settings.system-features = [ "gccarch-armv7-a" ];
      };
}
