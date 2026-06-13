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

    # https://discourse.nixos.org/t/26-05-systemd-tmpfiles-clean-protocol-driver-not-attached/78101/3
    systemd.package =
      lib.throwIfNot (pkgs.systemd.version == "260.1") "systemd version override outdated!"
        (
          pkgs.systemd.overrideAttrs (prevAttrs: {
            version = "260.2";
            src = prevAttrs.src.override {
              hash = "sha256-NXmmSV7/9WIW6C8wjdOwaerCy4v7Zcrd8+XDzcS8rEk=";
            };
          })
        );
  };
}
