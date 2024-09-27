{ pkgs, ... }:
let
  # To add yourself:
  # 1. Add an entry to this list, using the next UID.
  # 2. Create a file in `keys` named your user name that contains your SSH key(s), separated by newlines.

  # Note: currently the darwin build box doesn't support FIDO keys.
  # https://github.com/nix-community/infra/issues/1007
  users = [
    {
      name = "winter";
      trusted = true;
      uid = 502;
      keys = ./keys/winter;
    }
    {
      name = "stephank";
      trusted = true;
      uid = 503;
      keys = ./keys/stephank;
    }
    {
      name = "hexa";
      trusted = true;
      uid = 504;
      keys = ./keys/hexa;
    }
    {
      name = "0x4A6F";
      trusted = true;
      uid = 505;
      keys = ./keys/0x4A6F;
    }
    {
      name = "artturin";
      trusted = true;
      uid = 506;
      keys = ./keys/artturin;
    }
    {
      name = "figsoda";
      trusted = true;
      uid = 507;
      keys = ./keys/figsoda;
    }
    {
      name = "raitobezarius";
      trusted = true;
      uid = 508;
      keys = ./keys/raitobezarius;
    }
    {
      name = "k900";
      trusted = true;
      uid = 509;
      keys = ./keys/k900;
    }
    {
      name = "julienmalka";
      trusted = true;
      uid = 510;
      keys = ./keys/julienmalka;
    }
    {
      name = "dotlambda";
      trusted = true;
      uid = 511;
      keys = ./keys/dotlambda;
    }
    {
      name = "lily";
      trusted = true;
      uid = 512;
      keys = ./keys/lily;
    }
    {
      name = "ma27";
      trusted = true;
      uid = 513;
      keys = ./keys/ma27;
    }
    {
      name = "fab";
      trusted = true;
      uid = 514;
      keys = ./keys/fab;
    }
    {
      name = "phaer";
      trusted = true;
      uid = 515;
      keys = ./keys/phaer;
    }
    {
      name = "emilylange";
      trusted = true;
      uid = 516;
      keys = ./keys/emilylange;
    }
    {
      name = "emilytrau";
      trusted = true;
      uid = 517;
      keys = ./keys/emilytrau;
    }
    {
      name = "janik";
      trusted = true;
      uid = 518;
      keys = ./keys/janik;
    }
    {
      name = "delroth";
      trusted = true;
      uid = 519;
      keys = ./keys/delroth;
    }
    {
      name = "toonn";
      trusted = true;
      uid = 520;
      shell = pkgs.fish;
      keys = ./keys/toonn;
    }
    {
      name = "glepage";
      trusted = true;
      uid = 521;
      shell = pkgs.fish;
      keys = ./keys/glepage;
    }
    {
      name = "anthonyroussel";
      trusted = true;
      uid = 522;
      keys = ./keys/anthonyroussel;
    }
    {
      name = "sgo";
      trusted = true;
      uid = 523;
      keys = ./keys/sgo;
    }
    {
      name = "chayleaf";
      trusted = true;
      uid = 524;
      keys = ./keys/chayleaf;
    }
    {
      # https://github.com/lf-
      name = "jade";
      trusted = true;
      uid = 525;
      keys = ./keys/jade;
    }
    {
      name = "kranzes";
      trusted = true;
      uid = 526;
      keys = ./keys/kranzes;
    }
    {
      name = "sternenseemann";
      trusted = true;
      uid = 527;
      keys = ./keys/sternenseemann;
    }
    {
      name = "jtojnar";
      trusted = true;
      uid = 528;
      keys = ./keys/jtojnar;
    }
    {
      name = "corngood";
      trusted = true;
      uid = 529;
      keys = ./keys/corngood;
    }
    {
      name = "teto";
      trusted = true;
      uid = 530;
      keys = ./keys/teto;
    }
    {
      name = "matthewcroughan";
      trusted = true;
      uid = 531;
      keys = ./keys/matthewcroughan;
    }
    {
      name = "pennae";
      trusted = true;
      uid = 532;
      keys = ./keys/pennae;
    }
    {
      name = "jopejoe1";
      trusted = true;
      uid = 533;
      keys = ./keys/jopejoe1;
    }
    {
      name = "puckipedia";
      trusted = true;
      uid = 534;
      keys = ./keys/puckipedia;
    }
    {
      name = "kenji";
      trusted = true;
      uid = 535;
      keys = ./keys/kenji;
    }
    {
      name = "pinpox";
      trusted = true;
      uid = 536;
      keys = ./keys/pinpox;
    }
    {
      # https://github.com/n0emis
      name = "ember";
      trusted = true;
      uid = 537;
      keys = ./keys/ember;
    }
    {
      # lib.maintainers.nicoo, @nbraud on github.com
      name = "nicoo";
      trusted = true;
      uid = 538;
      keys = ./keys/nicoo;
    }
    {
      name = "imincik";
      trusted = true;
      uid = 539;
      keys = ./keys/imincik;
    }
    {
      name = "wolfgangwalther";
      trusted = true;
      uid = 540;
      keys = ./keys/wolfgangwalther;
    }
    {
      name = "tnias";
      trusted = true;
      uid = 541;
      keys = ./keys/tnias;
    }
    {
      # lib.maintainers.emily, https://github.com/emilazy
      name = "emily";
      trusted = true;
      uid = 542;
      keys = ./keys/emily;
    }
    {
      # lib.maintainers.johnrtitor, https://github.com/JohnRTitor
      name = "johnrtitor";
      trusted = true;
      uid = 543;
      keys = ./keys/johnrtitor;
    }
    {
      # lib.maintainers.kashw2, https://github.com/kashw2
      name = "kashw2";
      trusted = true;
      uid = 544;
      keys = ./keys/kashw2;
    }
    {
      # lib.maintainers.superherointj, https://github.com/superherointj
      name = "superherointj";
      trusted = true;
      uid = 545;
      keys = ./keys/superherointj;
    }
    {
      # lib.maintainers.SuperSandro2000, https://github.com/SuperSandro2000
      name = "sandro";
      trusted = true;
      uid = 546;
      keys = ./keys/sandro;
    }
    {
      # lib.maintainers.linj, https://github.com/jian-lin
      name = "linj";
      trusted = true;
      uid = 547;
      shell = pkgs.fish;
      keys = ./keys/linj;
    }
    {
      # lib.maintainers.pbsds, https://github.com/pbsds
      name = "pbsds";
      trusted = true;
      uid = 548;
      keys = ./keys/pbsds;
    }
    {
      # lib.maintainers.doronbehar, https://github.com/doronbehar
      name = "doronbehar";
      trusted = true;
      uid = 549;
      keys = ./keys/doronbehar;
    }
    {
      # lib.maintainers.aleksana, https://github.com/Aleksanaa
      name = "aleksana";
      trusted = true;
      uid = 550;
      keys = ./keys/aleksana;
    }
    {
      # lib.maintainers.khaneliman, https://github.com/khaneliman
      name = "khaneliman";
      trusted = true;
      uid = 551;
      keys = ./keys/khaneliman;
    }
  ];
in
{
  users.users = builtins.listToAttrs (
    builtins.map (u: {
      inherit (u) name;
      value = {
        inherit (u) uid;
        home = "/Users/${u.name}";
        createHome = true;
        shell = u.shell or "/bin/zsh";
        openssh.authorizedKeys.keyFiles = [ u.keys ];
      };
    }) users
  );

  users.knownUsers = builtins.map (u: u.name) users;

  users.forceRecreate = true;

  nix.settings.trusted-users = builtins.map (u: u.name) (builtins.filter (u: u.trusted) users);
}
