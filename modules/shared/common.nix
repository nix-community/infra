{ pkgs, lib, ... }:
{
  # Nix configuration shared between all hosts

  imports = [
    ./deploy.nix
    ./nix-settings.nix
  ];

  nix.settings.extra-platforms =
    lib.mkIf pkgs.stdenv.isDarwin [ "x86_64-darwin" "aarch64-darwin" ];

  nix.settings.builders-use-substitutes = true;

  nix.settings.max-jobs = lib.mkDefault "auto";
  nix.settings.keep-outputs = true; # Nice for developers
  nix.settings.keep-derivations = true; # Idem

  # garbage collection
  nix.settings.min-free = lib.mkOptionDefault (toString (1 * 1024 * 1024 * 1024));
  nix.settings.max-free = lib.mkOptionDefault (toString (11 * 1024 * 1024 * 1024));

  # Enable the automatic gc only to clean up gc-roots.
  # We always want to keep as much as possible in the store.
  # Actual deletion of store paths is done via 'nix.settings.min-free'.
  nix.gc =
    {
      automatic = true;
      options = lib.mkForce ''--max-freed "$((96* 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux (lib.mkForce {
      # run at all minutes that are a multiple of 7
      # verified with `systemd-analyze calendar "*-*-* *:0/7:00"`
      dates = "*-*-* *:0/7:00";
      # TODO: for some reason the timer is configured with RandomizedDelaySec=1800 regardless of this value
      randomizedDelaySec = "1min";
    })
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      # run at all minutes that are a multiple of 7
      intervals =
        builtins.map (Minute: { inherit Minute; }) (builtins.genList (n: n * 7) 9);
    };

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    nix
    gnugrep
    gnutar
    gzip
    coreutils
    libressl.nc
    procps
    xz
    zstd
    openssh
    tree
    tmux
    upterm
    gawk
    gitFull
    vim
    cachix
  ];
}
