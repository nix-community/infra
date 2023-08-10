{ config, ... }:
{
  # set $HOME to avoid 'warning: $HOME is not owned by you'
  # https://github.com/NixOS/nix/issues/6834
  # srvos
  system.activationScripts.preActivation.text = ''
    if [[ -e /run/current-system ]]; then
      echo "--- diff to current-system"
      HOME=/var/root ${config.nix.package}/bin/nix --extra-experimental-features nix-command store diff-closures /run/current-system "$systemConfig"
      echo "---"
    fi
  '';
}
