{ inputs, pkgs, ... }:
{
  imports = [
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    ../../shared/packages.nix
    ./builder.nix
    ./network.nix
    ./packages.nix
    ./reboot.nix
    ./security.nix
    ./software-update.nix
    ./sops-nix.nix
    ./telegraf.nix
    ./users.nix
    inputs.srvos.darwinModules.server
  ];

  launchd.daemons.nix-build-cleanup = {
    script = "${pkgs.findutils}/bin/find /nix/var/nix/builds -delete || true";
    serviceConfig = {
      KeepAlive = false;
      LaunchOnlyOnce = true;
      RunAtLoad = true;
      StandardErrorPath = "/var/log/nix-build-cleanup.log";
      StandardOutPath = "/var/log/nix-build-cleanup.log";
    };
  };

  system.activationScripts.postActivation.text = ''
    echo disabling spotlight indexing... >&2
    mdutil -a -i off -d &> /dev/null
    mdutil -a -E &> /dev/null
  '';
}
