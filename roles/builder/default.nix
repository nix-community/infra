{ ... }: {
  imports = [ ./users.nix ];

  nix.trustedUsers = [ "@trusted" ];
}
