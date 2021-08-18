{ config, lib, pkgs, ... }:
# build with:
# nix-shell -p nixos-generators --run 'nixos-generate -o ./result  -f kexec-bundle -c ./roles/kexec.nix'
{
  imports = [
    ./users.nix
    ./sshd.nix
  ];

  # ttyAMA0 is consoles on aarch64
  boot.kernelParams = [ "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0" ];
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
