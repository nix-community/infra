{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.self}/modules/shared/community-builder.nix"
    inputs.nix-index-database.darwinModules.nix-index
    ./users.nix
  ];

  environment.etc.motd.text = config.nixCommunity.motd;

  programs.bash.enable = true;

  environment.shells = [
    pkgs.bashInteractive
    pkgs.fish
    pkgs.zsh
  ];

  environment.systemPackages = [
    pkgs.vim
  ];

  launchd.daemons.nixpkgs-clone = {
    environment = {
      inherit (config.environment.variables) NIX_SSL_CERT_FILE;
    };
    serviceConfig = {
      StartCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
      StandardErrorPath = "/var/log/nixpkgs-clone.log";
      StandardOutPath = "/var/log/nixpkgs-clone.log";
    };
    path = [
      pkgs.git
    ];
    script = builtins.readFile "${inputs.self}/modules/shared/nixpkgs-clone.bash";
  };
}
