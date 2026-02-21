{ config, pkgs, ... }:
{
  imports = [
    ../../modules/shared/telegraf.nix
    ./ssh.nix
    ./telegraf-config.nix
    ./telegraf-service.nix
  ];

  nixpkgs.buildPlatform = "x86_64-linux";
  nixpkgs.hostPlatform = "x86_64-freebsd";

  networking.hostName = "nixbsd-freebsd";

  system.stateVersion = "25.05"; # silence warning

  services.openssh.enable = true;
  boot.loader.stand-freebsd.enable = true;
  networking.dhcpcd.wait = "background";

  nixbsd.enableExtraSubstituters = false;

  users.users.root.initialPassword = "toor";

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [
      "trusted"
      "wheel"
    ];
    inherit (config.users.users.root) initialPassword;
  };

  boot.tmp.useTmpfs = false;

  fileSystems."/" = {
    device = "/dev/gpt/nixos";
    fsType = "ufs";
  };

  fileSystems."/boot" = {
    device = "/dev/msdosfs/ESP";
    fsType = "msdosfs";
  };

  environment.systemPackages = with pkgs; [
    file
    freebsd.truss
    gitMinimal
    htop
    jq
    mini-tmpfiles
    tmux
    unzip
    vim
    zip
  ];

  users.users.nix = {
    isNormalUser = true;
    extraGroups = [ "trusted" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb root@nixos"
    ];
  };

  users.groups.trusted = { };

  nix.settings =
    let
      asGB = size: toString (size * 1024 * 1024 * 1024);
    in
    {
      max-jobs = 4;
      min-free = asGB 20;
      max-free = asGB 50;
      trusted-users = [
        "@trusted"
        "@wheel"
      ];
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://temp-cache.nix-community.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "temp-cache.nix-community.org-1:RSXIfGjilfBsilDvj03/VnL/9qAxacBnb1YQvSdCoDc="
      ];
    };

  virtualisation.vmVariant.virtualisation = {
    diskImage = "./disk.qcow2";
    rootSize = "100g";
    graphics = false;
    forwardPorts = [
      {
        from = "host";
        host.port = 31022;
        guest.port = 22;
      }
      {
        from = "host";
        host.port = 39273;
        guest.port = 9273;
      }
    ];
  };
}
