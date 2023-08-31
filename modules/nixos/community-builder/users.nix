{ pkgs, ... }:
let
  inherit (pkgs) lib;

  users = {
    # 1. Generate an SSH key for your root account and add the public
    #    key to a file matching your name in ./keys/
    #
    # 2. Copy / paste this in order, alphabetically:
    #
    #    youruser.keys = ./keys/youruser;
    #
    "0x4A6F".keys = ./keys/0x4A6F;

    a-kenji.keys = ./keys/a-kenji;

    bobby285271.keys = ./keys/bobby285271;

    ckie.keys = ./keys/ckie;

    fgaz.keys = ./keys/fgaz;

    flokli.keys = ./keys/flokli;

    janik.keys = ./keys/janik;

    jtojnar.keys = ./keys/jtojnar;

    lewo.keys = ./keys/lewo;

    lily.keys = ./keys/lily;

    networkexception.keys = ./keys/networkexception;

    raitobezarius.keys = ./keys/raitobezarius;

    schmittlauch.keys = ./keys/schmittlauch;


    matthiasbeyer = {
      trusted = false;
      keys = ./keys/matthiasbeyer;
    };

    stephank.keys = ./keys/stephank;

    winter.keys = ./keys/winter;
  };

  ifAttr = key: default: result: opts:
    if (opts ? "${key}") && opts."${key}"
    then result
    else default;

  maybeTrusted = ifAttr "trusted" [ ] [ "trusted" ];
  maybeWheel = ifAttr "sudo" [ ] [ "wheel" ];

  userGroups = opts:
    (maybeTrusted opts) ++
    (maybeWheel opts);

  descToUser = name: opts:
    {
      isNormalUser = true;
      extraGroups = userGroups opts;
      createHome = true;
      home = "/home/${name}";
      hashedPassword = opts.password or null;
      openssh.authorizedKeys.keyFiles = [
        opts.keys
      ];
    };
in
{
  users = {
    mutableUsers = false;
    users = lib.mapAttrs descToUser users;
  };
}
