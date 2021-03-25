{ config, lib, pkgs, ... }:
# build with:
# nix-shell -p nixos-generators --run 'nixos-generate -o ./result  -f kexec-bundle -c ./profiles/kexec.nix'
{
  imports = [
    ./users.nix
    ./sshd.nix
  ];
}

# Hetzner bootstrap from rescue system
#
#useradd -m -s /bin/bash foo
#install -d -m700 -o foo /nix
#su - foo
#curl -L https://nixos.org/nix/install | bash
#. /home/foo/.nix-profile/etc/profile.d/nix.sh
#git clone https://github.com/nix-community/infra && cd infra
#nix-shell
#nix-shell -p nixos-generators --run 'nixos-generate -o ./result  -f kexec-bundle -c ./roles/kexec.nix'
#exit
#exit
#/home/foo/infra/result
#after reboot:
#$  systemctl stop autoreboot.timer
