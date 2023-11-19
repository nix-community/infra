{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.common
    inputs.self.darwinModules.builder
    inputs.self.darwinModules.hercules-ci
    inputs.self.darwinModules.remote-builder
  ];

  # can be removed when we switch back to the nixpkgs hercules-ci-agent
  system.systemBuilderArgs.sandboxProfile = ''
    (allow file-read* file-write* process-exec mach-lookup (subpath "${builtins.storeDir}"))
  '';

  nix.settings.sandbox = "relaxed";
  nix.settings.extra-platforms = [ "x86_64-darwin" ];

  # disable nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  networking.hostName = "darwin02";

  system.stateVersion = 4;
}
