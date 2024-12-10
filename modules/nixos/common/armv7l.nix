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

        boot.kernelPatches =
          let
            name = "compat_uts_machine";
          in
          [
            {
              inherit name;
              patch = pkgs.fetchpatch {
                inherit name;
                url = "https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/jammy/patch/?id=c1da50fa6eddad313360249cadcd4905ac9f82ea";
                hash = "sha256-357+EzMLLt7IINdH0ENE+VcDXwXJMo4qiF/Dorp2Eyw=";
              };
            }
          ];

        nix.settings.extra-platforms = [ "armv7l-linux" ];
      };
}
