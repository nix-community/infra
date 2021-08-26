({ pkgs, ... }: {
  systemd.services.clone-nixpkgs = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    startAt = "daily";
    script = ''
      if [ -d /var/lib/nixpkgs.git ]; then
        ${pkgs.git}/bin/git -C /var/lib/nixpkgs.git fetch
      else
        ${pkgs.git}/bin/git clone --bare https://github.com/nixos/nixpkgs /var/lib/nixpkgs.git
      fi
    '';
  };
})
