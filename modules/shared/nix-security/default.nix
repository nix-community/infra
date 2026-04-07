{ config, pkgs, ... }:
{
  # Vendored fixes for two FOD-related nix vulnerabilities still in
  # upstream review:
  #
  #   - GHSA-g3g9-5vj6-r3gj: std::filesystem::copy_file follows symlinks
  #     when copying FOD outputs, allowing a malicious builder to overwrite
  #     files outside the build sandbox.
  #   - CVE-2025-46416: cooperating builders can smuggle file descriptors
  #     via abstract unix sockets; mitigated via landlock
  #     LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET on kernels >= 6.12.
  #
  # Patches are backported from https://git.ntd.one/nix-security/nix
  # against the 2.31.3 tag that nixpkgs pins. Override only nix.package so
  # we don't perturb the rest of pkgs; drop this module once the fixes land
  # upstream.
  nix =
    { }
    // pkgs.lib.optionalAttrs (config.networking.hostName != "build02") {
      package =
        (pkgs.nixVersions.nixComponents_2_31.appendPatches [
          ./patches/ghsa-g3g9-5vj6-r3gj-2.31.patch
          ./patches/CVE-2025-46416-2.31.patch
        ]).nix-everything;
    };
}
