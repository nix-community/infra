{ lib, pkgs, ... }: {
  users.knownGroups = [ "builder" ];
  users.knownUsers = [ "builder" ];

  users.groups.builder = {
    name = "builder";
    gid = lib.mkDefault 8765;
    description = "Group for remote build clients";
  };

  users.users.builder = {
    name = "builder";
    uid = lib.mkDefault 8765;
    home = lib.mkDefault "/Users/builder";
    createHome = true;
    shell = "/bin/bash";
    description = "User for remote build clients";
  };

  nix.settings.trusted-users = [ "builder" ];

  system.activationScripts.postActivation.text = ''
    # fixup bashrc for remote nix executions
    echo 'PATH=/nix/var/nix/profiles/default/bin:$PATH' > /Users/builder/.bashrc

    # allow builder usre to lock gc.lock
    chown builder /nix/var/nix/gc.lock

    # setup ssh credentials for remote builds
    mkdir -p /Users/builder/.ssh/
    echo "command=\"${pkgs.flock}/bin/flock -s /nix/var/nix/gc.lock nix-daemon --stdio\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1K1ZYBnf3UqQbln5Z8DLYsXyJo6pRAFISPQ7lJZpoO root@linux-builder-01" > /Users/builder/.ssh/authorized_keys
    chown -R builder:staff /Users/builder/.ssh/
    chmod 700 /Users/builder/.ssh/
    chmod 400 /Users/builder/.ssh/authorized_keys
    dseditgroup -o edit -a builder -t user com.apple.access_ssh

    # restart nix daemon if nix.conf changed
    if [ ! -e /etc/nix/nix.conf.old ] && ! diff -q /etc/nix/nix.conf /etc/nix/nix.conf.old; then
      cp /etc/nix/nix.conf /etc/nix/nix.conf.old
      launchctl stop org.nixos.nix-daemon
      launchctl start org.nixos.nix-daemon
    fi
  '';
}
