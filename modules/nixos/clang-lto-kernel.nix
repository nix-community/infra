{ pkgs, ... }:
let
  inherit (pkgs) pkgsLLVM;
in
{
  boot.kernelPackages = pkgsLLVM.linuxPackagesFor (
    pkgsLLVM.linuxKernel.packages.linux_6_12.kernel.override {
      structuredExtraConfig = with pkgsLLVM.lib.kernel; {
        LTO_CLANG_THIN = yes;
      };
    }
  );
}
