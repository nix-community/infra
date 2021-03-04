{ config, lib, pkgs, ... }:
# nix-shell -p nixos-generators --run 'nixos-generate -o ./result  -f kexec-bundle -c ./profiles/kexec.nix'
{
  imports = [
    ./users.nix
    ./sshd.nix
  ];
}
