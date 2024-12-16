{ config, pkgs, ... }:
{
  # adapted from:
  # https://github.com/Mic92/dotfiles/blob/020180880d9413e076073889f82c4751a27734e9/nixos/modules/update-prefetch.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/system/boot/kexec.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/tasks/auto-upgrade.nix
  systemd.services.update-host = {
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "30s";
    serviceConfig.Type = "oneshot";
    path = [
      config.nix.package
      config.systemd.package
      pkgs.coreutils
      pkgs.curl
      pkgs.kexec-tools
    ];
    script = builtins.readFile ./update.bash;
  };

  # https://gist.github.com/Ma27/6650d10f772511931647d3189b3eb1d7
  # https://github.com/NuschtOS/nixos-modules/blob/39d26dddae2f117d7f9c33dd1efc866ff684ff94/modules/nix.nix
  boot.loader.grub.extraInstallCommands = ''
    if [[ "''${NIXOS_ACTION-}" == boot && -e /run/current-system && -e "''${1-}" ]]; then
      echo "--- diff to current-system"
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "''${1-}"
      echo "---"
    fi
  '';

  systemd.timers.update-host = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnBootSec = "5m";
    timerConfig.OnUnitInactiveSec = "5m";
  };
}
