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

    binarycat = {
      trusted = true;
      keys = ./keys/binarycat;
    };

    binarycat-untrusted = {
      trusted = false;
      keys = ./keys/binarycat;
    };

    bobby285271 = {
      trusted = true;
      keys = ./keys/bobby285271;
    };

    ckie = {
      trusted = true;
      keys = ./keys/ckie;
    };

    fgaz = {
      trusted = true;
      keys = ./keys/fgaz;
    };

    flokli = {
      trusted = true;
      keys = ./keys/flokli;
    };

    fmzakari = {
      # github: @fzakaria
      trusted = true;
      keys = ./keys/fmzakari;
    };

    glepage = {
      trusted = true;
      keys = ./keys/glepage;
    };

    hexchen = {
      trusted = true;
      keys = ./keys/hexchen;
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

    nicoo = {
      # lib.maintainers.nicoo, @nbraud on github.com
      trusted = true;
      keys = ./keys/nicoo;
    };

    raitobezarius = {
      trusted = true;
      keys = ./keys/raitobezarius;
    };

    networkexception = {
      trusted = true;
      keys = ./keys/networkexception;
    };

    pinpox = {
      trusted = true;
      keys = ./keys/pinpox;
    };

    schmittlauch = {
      trusted = true;
      keys = ./keys/schmittlauch;
    };

    matthiasbeyer = {
      trusted = true;
      keys = ./keys/matthiasbeyer;
    };

    stephank = {
      trusted = true;
      keys = ./keys/stephank;
    };

    teto = {
      trusted = true;
      keys = ./keys/teto;
    };

    winter = {
      trusted = true;
      keys = ./keys/winter;
    };

    matthewcroughan = {
      trusted = true;
      keys = ./keys/matthewcroughan;
    };

    emily = {
      # lib.maintainers.emily, https://github.com/emilazy
      trusted = true;
      keys = ./keys/emily;
    };
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
