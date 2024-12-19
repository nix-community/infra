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

  environment.etc."ssh/sshd_config.d/security-key.conf".text = ''
    SecurityKeyProvider ${pkgs.sk-libfido2}/sk-libfido2.dylib
  '';

  environment.etc.motd.text = config.nixCommunity.motd;

  environment.systemPackages = [
    pkgs.ncurses # for terminfo
  ];

  programs.bash.enable = true;

  environment.shells = [
    pkgs.bashInteractive
    pkgs.fish
    pkgs.nushell
    pkgs.zsh
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
