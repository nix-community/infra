{ pkgs, ... }:
let
  llvm = pkgs.llvmPackages_21;
  kernel = pkgs.linuxKernel.kernels.linux_6_12;
in
{
  boot.kernelPackages = pkgs.linuxPackagesFor (
    kernel.override {
      # https://github.com/NixOS/nixpkgs/issues/142901
      stdenv = pkgs.overrideCC llvm.stdenv (llvm.stdenv.cc.override { inherit (llvm) bintools; });
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
