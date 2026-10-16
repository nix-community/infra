{
  config,
  lib,
  pkgs,
  ...
}:
let
  llvm = pkgs.llvmPackages;
  kernel = pkgs.linuxKernel.kernels.linux_6_18;
in
{
  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    boot.kernelPackages = pkgs.linuxPackagesFor (
      kernel.override {
        # https://github.com/NixOS/nixpkgs/issues/142901
        stdenv = pkgs.overrideCC llvm.stdenv (llvm.stdenv.cc.override { inherit (llvm) bintools; });
        ignoreConfigErrors = true; # config for clang+rust is broken, needs to be fixed in nixpkgs
        structuredExtraConfig =
          let
            inherit (pkgs.lib.kernel) yes;
          in
          {
            LTO_CLANG_THIN = yes;
          };
      }
    );
  };
}
