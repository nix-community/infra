{ inputs, ... }:
{
  imports = [
    ../../shared/sops-nix.nix
    inputs.sops-nix.nixosModules.sops
  ];

  sops.age.sshKeyFile = "/var/lib/ssh_secrets/ssh_host_ed25519_key";
}
