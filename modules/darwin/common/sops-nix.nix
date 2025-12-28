{ inputs, ... }:
{
  imports = [
    ../../shared/sops-nix.nix
    inputs.sops-nix.darwinModules.sops
  ];

  sops.age.sshKeyFile = "/etc/ssh/ssh_host_ed25519_key";

  # disable rsa key import, also removes gnupg packages from closure
  sops.gnupg.sshKeyPaths = [ ];
}
