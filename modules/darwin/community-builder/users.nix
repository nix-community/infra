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
      # wheel = true; admin group set manually
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
    {
      # lib.maintainers.perchun, https://github.com/PerchunPak
      name = "perchun";
      trusted = true;
      uid = 552;
      shell = pkgs.fish;
      keys = ./keys/perchun;
    }
    {
      # lib.maintainers.mrcjkb, https://github.com/mrcjkb
      name = "mrcjkb";
      trusted = true;
      uid = 553;
      shell = pkgs.zsh;
      keys = ./keys/mrcjkb;
    }
    {
      # lib.maintainers.fpletz, https://github.com/fpletz
      name = "fpletz";
      trusted = true;
      uid = 554;
      keys = ./keys/fpletz;
    }
    {
      # lib.maintainers.Enzime, https://github.com/Enzime
      name = "enzime";
      trusted = true;
      uid = 555;
      keys = ./keys/enzime;
    }
    {
      # lib.maintainers.artemist, https://github.com/artemist
      name = "artemist";
      trusted = true;
      uid = 556;
      keys = ./keys/artemist;
    }
    {
      # lib.maintainers.fliegendewurst, https://github.com/FliegendeWurst
      name = "fliegendewurst";
      trusted = true;
      uid = 557;
      keys = ./keys/FliegendeWurst;
    }
    {
      # lib.maintainers.numinit, https://github.com/numinit
      name = "numinit";
      trusted = true;
      uid = 558;
      keys = ./keys/numinit;
    }
    {
      # lib.maintainers.leona, https://github.com/leona-ya
      name = "leona";
      trusted = true;
      uid = 559;
      keys = ./keys/leona;
    }
    {
      # lib.maintainers.katexochen, https://github.com/katexochen
      name = "katexochen";
      trusted = true;
      uid = 560;
      keys = ./keys/katexochen;
    }
    {
      # lib.maintainers.booxter, https://github.com/booxter
      name = "booxter";
      trusted = true;
      uid = 561;
      keys = ./keys/booxter;
    }
    {
      # lib.maintainers.natsukium, https://github.com/natsukium
      name = "natsukium";
      trusted = true;
      uid = 562;
      keys = ./keys/natsukium;
    }
    {
      # lib.maintainers.hadilq, https://github.com/hadilq
      name = "hadilq";
      trusted = true;
      uid = 563;
      keys = ./keys/hadilq;
    }
    {
      # lib.maintainers.aciceri, https://github.com/aciceri
      name = "aciceri";
      trusted = true;
      uid = 564;
      keys = ./keys/aciceri;
    }
    {
      name = "jfly";
      trusted = true;
      uid = 565;
      keys = ./keys/jfly;
    }
    {
      # lib.maintainers.HeitorAugustoLN, https://github.com/HeitorAugustoLN
      name = "heitor";
      trusted = true;
      uid = 566;
      shell = pkgs.fish;
      keys = ./keys/heitor;
    }
    # lib.maintainers.davhau, https://github.com/davhau
    {
      name = "davhau";
      trusted = true;
      uid = 567;
      keys = ./keys/davhau;
    }
    {
      name = "adamcstephens";
      trusted = true;
      uid = 568;
      keys = ./keys/adamcstephens;
    }
    # lib.maintainers.marie, https://github.com/NyCodeGHG
    {
      name = "marie";
      trusted = true;
      uid = 569;
      shell = pkgs.fish;
      keys = ./keys/marie;
    }
    {
      name = "thecomputerguy";
      trusted = true;
      uid = 570;
      shell = pkgs.zsh;
      keys = ./keys/thecomputerguy;
    }
    {
      name = "raboof";
      # lib.maintainers.raboof, https://github.com/raboof
      trusted = true;
      uid = 571;
      keys = ./keys/raboof;
    }
    {
      # lib.maintainers.lukegb, https://github.com/lukegb
      name = "lukegb";
      trusted = true;
      uid = 572;
      keys = ./keys/lukegb;
    }
    {
      # lib.maintainers.grimmauld, https://github.com/lordgrimmauld
      name = "grimmauld";
      trusted = true;
      uid = 573;
      keys = ./keys/grimmauld;
    }
    {
      # lib.maintainers.cryolitia, https://github.com/cryolitia
      name = "cryolitia";
      trusted = true;
      uid = 574;
      keys = ./keys/cryolitia;
    }
    {
      # lib.maintainers.defelo, https://github.com/Defelo
      name = "defelo";
      trusted = true;
      uid = 575;
      keys = ./keys/defelo;
    }
    {
      # lib.maintainers.marcin-serwin, https://github.com/marcin-serwin
      name = "marcin-serwin";
      trusted = true;
      uid = 576;
      keys = ./keys/marcin-serwin;
    }
    {
      # lib.maintainers.prince213, https://github.com/Prince213
      name = "prince213";
      trusted = true;
      uid = 577;
      keys = ./keys/prince213;
    }
    {
      # lib.maintainers.mdaniels5757, https://github.com/mdaniels5757
      name = "mdaniels5757";
      trusted = true;
      uid = 578;
      keys = ./keys/mdaniels5757;
    }
    {
      # lib.maintainers.dramforever, https://github.com/dramforever
      name = "dramforever";
      trusted = true;
      uid = 579;
      keys = ./keys/dramforever;
    }
    {
      # lib.maintainers.sikmir, https://github.com/sikmir
      name = "sikmir";
      trusted = true;
      uid = 580;
      keys = ./keys/sikmir;
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

  nix.settings.trusted-users = builtins.map (u: u.name) (builtins.filter (u: u.trusted) users);
}
