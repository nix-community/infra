{
  # Make sure that the firewall is enabled, even if it's the default.
  networking.firewall.enable = true;

  programs.ssh.knownHosts = {
    build01 = {
      hostNames = [ "build01.nix-community.org" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElIQ54qAy7Dh63rBudYKdbzJHrrbrrMXLYl7Pkmk88H";
    };
    build02 = {
      hostNames = [ "build02.nix-community.org" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm3/o1HguyRL1z/nZxLBY9j/YUNXeNuDoiBLZAyt88Z";
    };
    build03 = {
      hostNames = [ "build03.nix-community.org" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiozp1A1+SUfJQPa5DZUQcVc6CZK2ZxL6FJtNdh+2TP";
    };
    build04 = {
      hostNames = [ "build04.nix-community.org" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU/gbREwVuI1p3ag1iG72jxl2/92yGl38c+TPOfFMH8";
    };
    aarch64-nixos-community = {
      hostNames = [ "aarch64.nixos.community" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUTz5i9u5H2FHNAmZJyoJfIGyUm/HfGhfwnc142L3ds";
    };
  };

  # Ban brute force SSH
  services.fail2ban.enable = true;
}
