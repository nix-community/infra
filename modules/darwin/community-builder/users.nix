{ pkgs, ... }:
let
  # To add yourself:
  # 1. Add an entry to this list
  # 2. Create a file in `keys` named your user name that contains your SSH key(s), separated by newlines.

  # Note: currently the darwin build box doesn't support FIDO keys.
  # https://github.com/nix-community/infra/issues/1007
  users = [
    {
      name = "winter";
      trusted = true;
      keys = ./keys/winter;
    }
    {
      name = "stephank";
      trusted = true;
      keys = ./keys/stephank;
    }
    {
      name = "hexa";
      trusted = true;
      keys = ./keys/hexa;
    }
    {
      name = "0x4A6F";
      trusted = true;
      keys = ./keys/0x4A6F;
    }
    {
      name = "artturin";
      trusted = true;
      keys = ./keys/artturin;
    }
    {
      name = "figsoda";
      trusted = true;
      keys = ./keys/figsoda;
    }
    {
      name = "raitobezarius";
      trusted = true;
      keys = ./keys/raitobezarius;
    }
    {
      name = "k900";
      trusted = true;
      keys = ./keys/k900;
    }
    {
      name = "julienmalka";
      trusted = true;
      keys = ./keys/julienmalka;
    }
    {
      name = "dotlambda";
      trusted = true;
      keys = ./keys/dotlambda;
    }
    {
      name = "lily";
      trusted = true;
      keys = ./keys/lily;
    }
    {
      name = "ma27";
      trusted = true;
      keys = ./keys/ma27;
    }
    {
      name = "fab";
      trusted = true;
      keys = ./keys/fab;
    }
    {
      name = "phaer";
      trusted = true;
      keys = ./keys/phaer;
    }
    {
      name = "emilylange";
      trusted = true;
      keys = ./keys/emilylange;
    }
    {
      name = "emilytrau";
      trusted = true;
      keys = ./keys/emilytrau;
    }
    {
      name = "janik";
      trusted = true;
      keys = ./keys/janik;
    }
    {
      name = "delroth";
      trusted = true;
      keys = ./keys/delroth;
    }
    {
      name = "toonn";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/toonn;
    }
    {
      name = "glepage";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/glepage;
    }
    {
      name = "anthonyroussel";
      trusted = true;
      keys = ./keys/anthonyroussel;
    }
    {
      name = "sgo";
      trusted = true;
      keys = ./keys/sgo;
    }
    {
      name = "chayleaf";
      trusted = true;
      keys = ./keys/chayleaf;
    }
    {
      # https://github.com/lf-
      name = "jade";
      trusted = true;
      keys = ./keys/jade;
    }
    {
      name = "kranzes";
      trusted = true;
      keys = ./keys/kranzes;
    }
    {
      name = "sternenseemann";
      trusted = true;
      keys = ./keys/sternenseemann;
    }
    {
      name = "jtojnar";
      trusted = true;
      keys = ./keys/jtojnar;
    }
    {
      name = "corngood";
      trusted = true;
      keys = ./keys/corngood;
    }
    {
      name = "teto";
      trusted = true;
      keys = ./keys/teto;
    }
    {
      name = "matthewcroughan";
      trusted = true;
      keys = ./keys/matthewcroughan;
    }
    {
      name = "pennae";
      trusted = true;
      keys = ./keys/pennae;
    }
    {
      name = "jopejoe1";
      trusted = true;
      keys = ./keys/jopejoe1;
    }
    {
      name = "puckipedia";
      trusted = true;
      keys = ./keys/puckipedia;
    }
    {
      name = "kenji";
      trusted = true;
      keys = ./keys/kenji;
    }
    {
      name = "pinpox";
      trusted = true;
      keys = ./keys/pinpox;
    }
    {
      # https://github.com/n0emis
      name = "ember";
      trusted = true;
      keys = ./keys/ember;
    }
    {
      # lib.maintainers.nicoo, @nbraud on github.com
      name = "nicoo";
      trusted = true;
      keys = ./keys/nicoo;
    }
    {
      name = "imincik";
      trusted = true;
      keys = ./keys/imincik;
    }
    {
      name = "wolfgangwalther";
      trusted = true;
      keys = ./keys/wolfgangwalther;
    }
    {
      name = "tnias";
      trusted = true;
      keys = ./keys/tnias;
    }
    {
      # lib.maintainers.emily, https://github.com/emilazy
      name = "emily";
      trusted = true;
      keys = ./keys/emily;
    }
    {
      # lib.maintainers.johnrtitor, https://github.com/JohnRTitor
      name = "johnrtitor";
      trusted = true;
      keys = ./keys/johnrtitor;
    }
    {
      # lib.maintainers.kashw2, https://github.com/kashw2
      name = "kashw2";
      trusted = true;
      keys = ./keys/kashw2;
    }
    {
      # lib.maintainers.superherointj, https://github.com/superherointj
      name = "superherointj";
      trusted = true;
      keys = ./keys/superherointj;
    }
    {
      # lib.maintainers.SuperSandro2000, https://github.com/SuperSandro2000
      name = "sandro";
      trusted = true;
      keys = ./keys/sandro;
    }
    {
      # lib.maintainers.linj, https://github.com/jian-lin
      name = "linj";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/linj;
    }
    {
      # lib.maintainers.pbsds, https://github.com/pbsds
      name = "pbsds";
      trusted = true;
      keys = ./keys/pbsds;
    }
    {
      # lib.maintainers.doronbehar, https://github.com/doronbehar
      name = "doronbehar";
      trusted = true;
      keys = ./keys/doronbehar;
    }
    {
      # lib.maintainers.aleksana, https://github.com/Aleksanaa
      name = "aleksana";
      trusted = true;
      keys = ./keys/aleksana;
    }
    {
      # lib.maintainers.khaneliman, https://github.com/khaneliman
      name = "khaneliman";
      trusted = true;
      keys = ./keys/khaneliman;
    }
    {
      # lib.maintainers.perchun, https://github.com/PerchunPak
      name = "perchun";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/perchun;
    }
    {
      # lib.maintainers.mrcjkb, https://github.com/mrcjkb
      name = "mrcjkb";
      trusted = true;
      shell = pkgs.nushell;
      keys = ./keys/mrcjkb;
    }
  ];
in
{
  users.users = builtins.listToAttrs (
    builtins.map (u: {
      inherit (u) name;
      value = {
        isNormalUser = true;
        home = "/Users/${u.name}";
        createHome = true;
        shell = u.shell or "/bin/zsh";
        openssh.authorizedKeys.keyFiles = [ u.keys ];
      };
    }) users
  );

  nix.settings.trusted-users = builtins.map (u: u.name) (builtins.filter (u: u.trusted) users);
}
