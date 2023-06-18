{ pkgs, ... }:
{
  # Garbage-collect often
  nix.gc.automatic = true;
  nix.gc.options = pkgs.lib.mkForce ''--max-freed "$((128 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

  # Give restricted SSH access to the build scheduler
  # on nix-darwin keys are copied, not symlinked
  users.users.nix-remote-builder.openssh.authorizedKeys.keys = [
    ''command="nix-daemon --stdio",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder''
  ];

  nix.settings.trusted-users = [ "nix-remote-builder" ];
}
