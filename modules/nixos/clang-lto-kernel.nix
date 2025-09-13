{ pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/pull/390631
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.linux.override {
      stdenv = pkgs.overrideCC pkgs.llvmPackages.stdenv (
        pkgs.llvmPackages.stdenv.cc.override {
          bintools = pkgs.llvmPackages.bintools;
        }
      );
      structuredExtraConfig =
        let
          inherit (pkgs.lib.kernel) option yes unset;
          inherit (pkgs.lib) mkForce;
        in
        {
          LTO_CLANG_THIN = yes;
          DRM_PANIC_SCREEN_QR_CODE = mkForce unset;
          RUST = mkForce (option yes);
        };
    }
  );
}
