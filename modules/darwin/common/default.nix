{ inputs, ... }:
{
  imports = [
    inputs.srvos.darwinModules.server
    ./network.nix
    ./packages.nix
    ./reboot.nix
    ./software-update.nix
    ./telegraf.nix
    ./users.nix
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    inputs.agenix.darwinModules.age
  ];

  # https://github.com/NixOS/nix/issues/7273
  nix.settings.auto-optimise-store = false;

  environment.etc."ssh/sshd_config.d/darwin.conf".text = ''
    HostKey /etc/ssh/ssh_host_ed25519_key
  '';

  system.activationScripts.postActivation.text = ''
    echo disabling spotlight indexing... >&2
    mdutil -a -i off -d &> /dev/null
    mdutil -a -E &> /dev/null
  '';

  services.rosetta2-gc = {
    enable = true;
    interval = [
      {
        Hour = 2;
        Minute = 30;
      }
    ];
  };
}
