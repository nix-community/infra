{ pkgs, lib, config, ... }:
let
  userLib = import ../users/lib.nix { inherit lib; };

  sources = import ../nix/sources.nix;
  nixpkgs-update = import sources.nixpkgs-update { };

  nixpkgs-update-bin = "${nixpkgs-update}/bin/nixpkgs-update";

  nixpkgsUpdateSystemDependencies = with pkgs; [
    nix # for nix-shell used by python packges to update fetchers
    git # used by update-scripts
    gnugrep
    gnused
    curl
    getent # used by hub
    cachix
  ];

  nixpkgs-update-github-releases = "${sources.nixpkgs-update-github-releases}/main.py";
  nixpkgs-update-pypi-releases = "${sources.nixpkgs-update-pypi-releases}/main.py";

  mkNixpkgsUpdateService = name: {
    description = "nixpkgs-update ${name} service";
    enable = true;
    startAt = "daily";
    restartIfChanged = false;
    path = nixpkgsUpdateSystemDependencies;
    environment.XDG_CONFIG_HOME = "/var/lib/nixpkgs-update/${name}";
    environment.XDG_CACHE_HOME = "/var/cache/nixpkgs-update/${name}";
    environment.XDG_RUNTIME_DIR = "/run/nixpkgs-update/${name}"; # for nix-update update scripts
    # API_TOKEN is used by nixpkgs-update-github-releases
    environment.API_TOKEN_FILE = "/var/lib/nixpkgs-update/github_token_with_username.txt";
    # Used by nixpkgs-update-github-releases to install python dependencies
    # Used by nixpkgs-update-pypi-releases
    environment.NIX_PATH = "nixpkgs=/var/cache/nixpkgs-update/${name}/nixpkgs";

    serviceConfig = {
      Type = "simple";
      User = "r-ryantm";
      Group = "r-ryantm";
      WorkingDirectory = "/var/lib/nixpkgs-update/${name}";
      StateDirectory = "nixpkgs-update/${name}";
      StateDirectoryMode = "700";
      CacheDirectory = "nixpkgs-update/${name}";
      CacheDirectoryMode = "700";
      LogsDirectory = "nixpkgs-update/${name}";
      LogsDirectoryMode = "755";
      RuntimeDirectory = "nixpkgs-update/${name}";
      RuntimeDirectoryMode = "700";
      StandardOutput = "journal";
    };
  };

  nixpkgs-update-command = "${nixpkgs-update-bin} update-list --pr --outpaths --nixpkgs-review";

in
{
  users.groups.r-ryantm = { };
  users.users.r-ryantm = {
    useDefaultShell = true;
    isNormalUser = true; # The hub cli seems to really want stuff to be set up like a normal user
    uid = userLib.mkUid "rrtm";
    extraGroups = [ "r-ryantm" ];
  };

  systemd.services.nixpkgs-update-repology = mkNixpkgsUpdateService "repology" // {
    script = ''
      ${nixpkgs-update-bin} delete-done --delete
      ${nixpkgs-update-bin} fetch-repology > /var/lib/nixpkgs-update/repology/packages-to-update-regular.txt
      # reverse list
      sed '1!G;h;$!d' /var/lib/nixpkgs-update/repology/packages-to-update-regular.txt > /var/lib/nixpkgs-update/repology/packages-to-update.txt
      ${nixpkgs-update-command}
    '';
  };

  systemd.services.nixpkgs-update-github = mkNixpkgsUpdateService "github" // {
    script = ''
      ${nixpkgs-update-bin} delete-done --delete
      ${nixpkgs-update-github-releases} > /var/lib/nixpkgs-update/github/packages-to-update.txt
      ${nixpkgs-update-command}
    '';
  };

  systemd.services.nixpkgs-update-pypi = mkNixpkgsUpdateService "pypi" // {
    script = ''
      ${nixpkgs-update-bin} delete-done --delete
      grep -rl $XDG_CACHE_HOME/nixpkgs -e buildPython | grep default | \
        ${nixpkgs-update-pypi-releases} --nixpkgs=/var/cache/nixpkgs-update/pypi/nixpkgs > /var/lib/nixpkgs-update/pypi/packages-to-update.txt
      ${nixpkgs-update-command}
    '';
  };

  systemd.services.nixpkgs-update-updatescript = mkNixpkgsUpdateService "updatescript" // {
    script = ''
      ${nixpkgs-update-bin} delete-done --delete
      ${pkgs.nixUnstable}/bin/nix eval --raw -f ${./packages-with-update-script.nix} > /var/lib/nixpkgs-update/updatescript/packages-to-update.txt
      ${nixpkgs-update-bin} update-list --pr --outpaths --nixpkgs-review --attrpath
    '';
  };

  systemd.services.nixpkgs-update-test-cachix = mkNixpkgsUpdateService "test-cachix" // {
    script = ''
      echo $HOME
      ls -la $HOME/.config/cachix
      cachix push nix-community /nix/store/24j9hfzwddscpzz3027hcd1rzm0ar1v9-xh-0.14.1
    '';
  };


  programs.ssh.knownHosts.github-rsa = {
    hostNames = [ "github.com" ];
    publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
  };

  programs.ssh.knownHosts.github-ed25519= {
    hostNames = [ "github.com" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  systemd.tmpfiles.rules = [
    "L /home/r-ryantm/.gitconfig - - - - ${./gitconfig.txt}"
    "d /home/r-ryantm/.ssh 700 r-ryantm r-ryantm - -"
    "e /var/cache/nixpkgs-update/repology/nixpkgs-review - - - 1d -"
    "e /var/cache/nixpkgs-update/github/nixpkgs-review - - - 1d -"
    "e /var/cache/nixpkgs-update/pypi/nixpkgs-review - - - 1d -"
    "e /var/cache/nixpkgs-update/updatescript/nixpkgs-review - - - 1d -"
    "L /var/lib/nixpkgs-update/repology/github_token.txt - - - - ${config.sops.secrets.github-r-ryantm-token.path}"
    "L /var/lib/nixpkgs-update/github/github_token.txt - - - - ${config.sops.secrets.github-r-ryantm-token.path}"
    "L /var/lib/nixpkgs-update/pypi/github_token.txt - - - - ${config.sops.secrets.github-r-ryantm-token.path}"
    "L /var/lib/nixpkgs-update/updatescript/github_token.txt - - - - ${config.sops.secrets.github-r-ryantm-token.path}"

    "L /var/lib/nixpkgs-update/repology/cachix/cachix.dhall - - - - ${config.sops.secrets.nix-community-cachix.path}"
    "L /var/lib/nixpkgs-update/github/cachix/cachix.dhall - - - - ${config.sops.secrets.nix-community-cachix.path}"
    "L /var/lib/nixpkgs-update/pypi/cachix/cachix.dhall - - - - ${config.sops.secrets.nix-community-cachix.path}"
    "L /var/lib/nixpkgs-update/updatescript/cachix/cachix.dhall - - - - ${config.sops.secrets.nix-community-cachix.path}" ];

  sops.secrets.github-r-ryantm-key = {
    path = "/home/r-ryantm/.ssh/id_rsa";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.github-r-ryantm-token = {
    path = "/var/lib/nixpkgs-update/github_token.txt";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.github-token-with-username = {
    path = "/var/lib/nixpkgs-update/github_token_with_username.txt";
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  sops.secrets.nix-community-cachix = {
    path = "/home/r-ryantm/.config/cachix/cachix.dhall";
    sopsFile = ../roles/nix-community-cache.yaml;
    owner = "r-ryantm";
    group = "r-ryantm";
  };

  services.nginx.virtualHosts."r.ryantm.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/log/" = {
      alias = "/var/log/nixpkgs-update/";
      extraConfig = ''
        charset utf-8;
        autoindex on;
      '';
    };
  };

}
