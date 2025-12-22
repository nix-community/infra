{
  config,
  lib,
  pkgs,
  ...
}:
let
  llvm = pkgs.llvmPackages_21;
  kernel = pkgs.linuxKernel.kernels.linux_6_18;
in
{
  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    boot.kernelPackages = pkgs.linuxPackagesFor (
      kernel.override {
        # https://github.com/NixOS/nixpkgs/issues/142901
        stdenv = pkgs.overrideCC llvm.stdenv (llvm.stdenv.cc.override { inherit (llvm) bintools; });
        structuredExtraConfig =
          let
            inherit (pkgs.lib.kernel) yes unset;
            inherit (pkgs.lib) mkForce;
          in
          {
            LTO_CLANG_THIN = yes;
            DEBUG_INFO_BTF = mkForce unset;
            NET_SCH_BPF = mkForce unset;
            SCHED_CLASS_EXT = mkForce unset;
          };
      }
    );
  };
}
