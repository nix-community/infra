{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.self}/modules/shared/community-builder.nix"
    inputs.nix-index-database.nixosModules.nix-index
    ./users.nix
  ];

  users.motd = config.nixCommunity.motd;

  environment.systemPackages = [
    # terminfo packages
    pkgs.foot.terminfo
    pkgs.kitty.terminfo
    pkgs.termite.terminfo
    pkgs.wezterm.terminfo
  ];

  programs.mosh = {
    enable = true;
    withUtempter = false;
  };

  systemd.services.nixpkgs-clone = {
    serviceConfig.Type = "oneshot";
    startAt = "daily";
    path = [
      pkgs.git
    ];
    script = builtins.readFile "${inputs.self}/modules/shared/nixpkgs-clone.bash";
  };
}
