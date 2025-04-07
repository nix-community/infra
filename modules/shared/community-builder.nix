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

  config = {
    nixCommunity.motd = ''

      Welcome to Nix Community!

      Please join our matrix room:

      https://matrix.to/#/#nix-community:nixos.org

      For a faster Nixpkgs clone use:

      git clone --reference /var/lib/nixpkgs.git https://github.com/NixOS/nixpkgs.git

    '';

    sops.secrets.community-builder-nix-access-tokens = {
      sopsFile = "${inputs.self}/modules/secrets/community-builder.yaml";
      mode = "444";
    };

    # fine-grained, no permissions github token, expires 2025-10-29
    # from `nix-community-buildbot` (user account, not the github app)
    nix.extraOptions = ''
      !include ${config.sops.secrets.community-builder-nix-access-tokens.path}
    '';

    # useful for people that want to test stuff
    environment.systemPackages =
      [
        pkgs.btop
        (pkgs.emacs.override { withNativeCompilation = !pkgs.stdenv.hostPlatform.isDarwin; })
        pkgs.fd
        pkgs.git
        pkgs.nano
        pkgs.nix-output-monitor
        pkgs.nix-tree
        pkgs.nixpkgs-review
        pkgs.ripgrep
        pkgs.tig
      ]
      ++ builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
        pkgs.foot.terminfo
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
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
      promptInit = ""; # otherwise it'll override the grml prompt
    };
  };
}
