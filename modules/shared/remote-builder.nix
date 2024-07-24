{
  config,
  lib,
  pkgs,
  ...
}:
let
  # https://discourse.nixos.org/t/wrapper-to-restrict-builder-access-through-ssh-worth-upstreaming/25834
  nix-ssh-wrapper = pkgs.writeShellScript "nix-ssh-wrapper" ''
    case $SSH_ORIGINAL_COMMAND in
      "nix-daemon --stdio")
        exec ${config.nix.package}/bin/nix-daemon --stdio
        ;;
      "nix-store --serve --write")
        exec ${config.nix.package}/bin/nix-store --serve --write
        ;;
      *)
        echo "Access only allowed for using the nix remote builder" 1>&2
        exit
    esac
  '';
in
{
  options.nixCommunity.remote-builder.key = lib.mkOption {
    type = lib.types.singleLineStr;
    default = null;
    description = "ssh public key for the remote build user";
  };

  config.users.users.nix.openssh.authorizedKeys.keys = [
    # use nix-store for hydra which doesn't support ssh-ng
    ''restrict,command="${nix-ssh-wrapper}" ${config.nixCommunity.remote-builder.key}''
  ];

  config.nix.settings.trusted-users = [ "nix" ];
}
