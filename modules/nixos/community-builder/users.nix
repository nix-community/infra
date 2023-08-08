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
    "0x4A6F" = {
      trusted = true;
      keys = ./keys/0x4A6F;
    };

    a-kenji = {
      trusted = true;
      keys = ./keys/a-kenji;
    };

    bobby285271.keys = ./keys/bobby285271;

    ckie.keys = ./keys/ckie;

    fgaz = {
      trusted = true;
      keys = ./keys/fgaz;
    };

    flokli = {
      trusted = true;
      keys = ./keys/flokli;
    };

    janik = {
      trusted = true;
      keys = ./keys/janik;
    };

    jtojnar = {
      trusted = true;
      keys = ./keys/jtojnar;
    };

    lewo = {
      trusted = true;
      keys = ./keys/lewo;
    };

    lily = {
      trusted = true;
      keys = ./keys/lily;
    };

    raitobezarius = {
      trusted = true;
      keys = ./keys/raitobezarius;
    };

    schmittlauch = {
      trusted = true;
      keys = ./keys/schmittlauch;
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
