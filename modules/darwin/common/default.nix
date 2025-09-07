{ inputs, pkgs, ... }:
{
  imports = [
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    ./apfs-cleanup.nix
    ./builder.nix
    ./network.nix
    ./packages.nix
    ./reboot.nix
    ./software-update.nix
    ./sops-nix.nix
    ./telegraf.nix
    ./users.nix
    inputs.srvos.darwinModules.server
  ];

  nix.package = pkgs.nix.overrideAttrs (o: {
    patches = o.patches or [ ] ++ [
      (pkgs.fetchpatch {
        # Fix macOS HUP detection using kqueue instead of poll
        url = "https://github.com/NixOS/nix/commit/1286d5db78701a5c0a83ae6b5f838b9ac60a61c1.patch";
        hash = "sha256-zJNzMyFf5Jq+UTYHx3AZl6MVc2I5CKk3YwvcZvuG2bE=";
      })
    ];
  });

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
}
