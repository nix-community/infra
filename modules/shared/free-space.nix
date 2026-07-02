{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.nixCommunity.free-space-cmd = lib.mkOption {
    type = lib.types.str;
  };
  config.nixCommunity.free-space-cmd = lib.getExe (
    pkgs.writeShellApplication {
      name = "free-space";
      runtimeInputs = [
        config.nix.package
        inputs.fast-nix-gc.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.coreutils
        pkgs.gawk
      ];
      text = builtins.readFile ./free-space.bash;
    }
  );
}
