{ inputs, testers, ... }:
testers.nixosTest {
  name = "kernel-clang-lto";
  nodes.host = {
    # needed to match the armv7l mkIf
    networking.hostName = "build";
    networking.hostId = "deadbeef";
    boot.supportedFilesystems = [ "zfs" ];
    imports = [
      inputs.srvos.nixosModules.server
      # import armv7l kernelPatches to match aarch64 host kernel config
      "${inputs.self}/modules/nixos/common/armv7l.nix"
      "${inputs.self}/modules/nixos/common/kernel.nix"
    ];
  };
  testScript = ''
    host.start()
    host.wait_for_unit("multi-user.target")
    host.succeed("zgrep CONFIG_CC_IS_CLANG=y /proc/config.gz")
    host.succeed("zgrep CONFIG_LD_IS_LLD=y /proc/config.gz")
    host.succeed("zgrep CONFIG_RUST_IS_AVAILABLE=y /proc/config.gz")
    host.succeed("zgrep CONFIG_LTO_CLANG_THIN=y /proc/config.gz")
    host.succeed("lsmod | grep ^zfs")
    host.shutdown()
  '';
}
