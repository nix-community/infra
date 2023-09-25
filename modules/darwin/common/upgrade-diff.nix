{ config, pkgs, ... }:
{
  # set $HOME to avoid 'warning: $HOME is not owned by you'
  # https://github.com/NixOS/nix/issues/6834
  # srvos
  system.activationScripts.preActivation.text = ''
    if [[ -e /run/current-system ]]; then
      echo "--- diff to current-system"
      HOME=/var/root ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
      echo "---"
    fi
  '';
}
