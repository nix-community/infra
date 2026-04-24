{
  config,
  lib,
  pkgs,
  ...
}:
let
  llvm = pkgs.llvmPackages_22;
  kernel = pkgs.linuxKernel.kernels.linux_6_18;
in
{
  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    nixpkgs.overlays = [
      (_: prev: {
        rust-bindgen-unwrapped = prev.rust-bindgen-unwrapped.override {
          inherit (llvm) clang;
        };
      })
    ];
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

    systemd.package = pkgs.systemd.overrideAttrs (o: {
      patches = o.patches ++ [
        (pkgs.fetchpatch {
          name = "tmpfiles:_do_not_require_STATX_ATIME.patch";
          url = "https://github.com/systemd/systemd/pull/41232.patch";
          hash = "sha256-PDh4mP9rYGCglp25346nExU2v6P0WYPfLZgu+YwzZ9c=";
        })
      ];
    });
  };
}
