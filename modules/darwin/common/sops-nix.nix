{ inputs, ... }:
{
  imports = [
    ../../shared/sops-nix.nix
    inputs.sops-nix.darwinModules.sops
  ];

  # disable rsa key import, also removes gnupg packages from closure
  sops.gnupg.sshKeyPaths = [ ];
}
