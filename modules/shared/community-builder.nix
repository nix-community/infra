{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.nixCommunity.motd = lib.mkOption {
    type = lib.types.str;
    description = "message of the day";
  };
  options.nixCommunity.threads = lib.mkOption {
    type = lib.types.int;
  };

  config = {
    nixCommunity.motd = ''

      Welcome to Nix Community!

      Please join our matrix room:

      https://matrix.to/#/#nix-community:nixos.org

      For a faster Nixpkgs clone use:

      git clone --reference /var/lib/nixpkgs.git https://github.com/NixOS/nixpkgs.git

    '';

    nix.settings.cores = config.nixCommunity.threads / 4;
    nix.settings.max-jobs = config.nixCommunity.threads / 4;

    sops.secrets.community-builder-nix-access-tokens = {
      sopsFile = "${inputs.self}/modules/secrets/community-builder.yaml";
      mode = "444";
    };

    # fine-grained, no permissions github token, expires 2026-10-23
    # from `nix-community-buildbot` (user account, not the github app)
    nix.extraOptions = ''
      !include ${config.sops.secrets.community-builder-nix-access-tokens.path}
    '';

    # useful for people that want to test stuff
    environment.systemPackages = [
      pkgs.btop
      pkgs.emacs
      pkgs.fd
      pkgs.git
      pkgs.nano
      pkgs.nix-output-monitor
      pkgs.nix-tree
      pkgs.nixpkgs-review
      pkgs.ripgrep
      pkgs.tig
    ]
    ++ builtins.filter (pkg: !pkg.meta.broken && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg) [
      pkgs.foot.terminfo
      pkgs.ghostty.terminfo
      pkgs.kitty.terminfo
      pkgs.termite.terminfo
      pkgs.wezterm.terminfo
    ];

    srvos.server.docs.enable = true;

    programs.nix-index-database.comma.enable = true;

    programs.fish = {
      enable = true;
      # puts /run/current-system/sw/bin in PATH for remote builds on darwin
      useBabelfish = true;
    };

    programs.zsh = {
      enable = true;
      # https://grml.org/zsh/grmlzshrc.html
      # https://grml.org/zsh/grml-zsh-refcard.pdf
      interactiveShellInit = ''
        export NOPATHHELPER=1 # disable macos path_helper
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
      promptInit = ""; # otherwise it'll override the grml prompt
    };
  };
}
