{ config, pkgs, ... }:

let

  postBuildHook = pkgs.writeScript "post-build-hook.sh" ''
    #!${pkgs.runtimeShell}
    exec ${pkgs.cachix}/bin/cachix -c /var/lib/post-build-hook/nix-community-cachix.dhall push nix-community $OUT_PATHS
  '';

in {

  nix.extraOptions = ''
    post-build-hook = ${postBuildHook}
  '';

}
