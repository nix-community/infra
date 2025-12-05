{ config, pkgs, ... }:
let
  users = [
    # To add yourself:
    # 1. Add an entry to this list.
    # 2. Create a file in `keys` named your user name that contains your SSH key(s), separated by newlines.
    {
      name = "0x4A6F";
      trusted = true;
      keys = ./keys/0x4A6F;
    }
    {
      name = "aciceri";
      trusted = true;
      keys = ./keys/aciceri;
    }
    {
      name = "adamcstephens";
      trusted = true;
      keys = ./keys/adamcstephens;
    }
    {
      name = "afh";
      trusted = true;
      keys = ./keys/afh;
    }
    {
      name = "a-kenji";
      trusted = true;
      keys = ./keys/a-kenji;
    }
    {
      name = "binarycat";
      trusted = true;
      keys = ./keys/binarycat;
    }
    {
      name = "binarycat-untrusted";
      trusted = false;
      keys = ./keys/binarycat;
    }
    {
      name = "bobby285271";
      trusted = true;
      keys = ./keys/bobby285271;
    }
    {
      name = "ckie";
      trusted = true;
      keys = ./keys/ckie;
    }
    {
      name = "dandellion";
      trusted = true;
      keys = ./keys/dandellion;
    }
    # lib.maintainers.davhau, https://github.com/davhau
    {
      name = "davhau";
      trusted = true;
      keys = ./keys/davhau;
    }
    {
      # https://github.com/dwt
      name = "dwt";
      trusted = true;
      keys = ./keys/dwt;
    }
    {
      # https://github.com/ethancedwards8
      # lib.maintainers.ethancedwards8
      name = "ethancedwards8";
      trusted = true;
      keys = ./keys/ethancedwards8;
    }
    {
      name = "fgaz";
      trusted = true;
      keys = ./keys/fgaz;
    }
    {
      name = "flokli";
      trusted = true;
      keys = ./keys/flokli;
    }
    {
      name = "fmzakari";
      # github: @fzakaria
      trusted = true;
      keys = ./keys/fmzakari;
    }
    {
      name = "glepage";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/glepage;
    }
    {
      # lib.maintainers.grimmauld, https://github.com/lordgrimmauld
      name = "grimmauld";
      trusted = true;
      keys = ./keys/grimmauld;
    }
    {
      name = "hadilq";
      trusted = true;
      keys = ./keys/hadilq;
    }
    {
      name = "hexchen";
      trusted = true;
      keys = ./keys/hexchen;
    }
    {
      name = "janik";
      trusted = true;
      keys = ./keys/janik;
    }
    {
      name = "jfly";
      trusted = true;
      keys = ./keys/jfly;
    }
    {
      name = "johnrtitor";
      trusted = true;
      keys = ./keys/johnrtitor;
    }
    {
      name = "jtojnar";
      trusted = true;
      keys = ./keys/jtojnar;
    }
    {
      # lib.maintainers.katexochen, https://github.com/katexochen
      name = "katexochen";
      trusted = true;
      keys = ./keys/katexochen;
    }
    {
      # lib.maintainers.khaneliman, https://github.com/khaneliman
      name = "khaneliman";
      trusted = true;
      keys = ./keys/khaneliman;
    }
    {
      name = "lewo";
      trusted = true;
      keys = ./keys/lewo;
    }
    {
      name = "lily";
      trusted = true;
      keys = ./keys/lily;
    }
    {
      name = "linj";
      # lib.maintainers.linj, https://github.com/jian-lin
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/linj;
    }
    {
      name = "misuzu";
      # lib.maintainers.misuzu https://github.com/misuzu
      trusted = true;
      keys = ./keys/misuzu;
    }
    {
      name = "mrcjkb";
      # lib.maintainers.mrcjkb https://github.com/mrcjkb
      trusted = true;
      shell = pkgs.zsh;
      keys = ./keys/mrcjkb;
    }
    {
      name = "nicoo";
      # lib.maintainers.nicoo, @nbraud on github.com
      trusted = true;
      keys = ./keys/nicoo;
    }
    {
      name = "NobbZ";
      trusted = true;
      keys = ./keys/nobbz;
    }
    {
      name = "raitobezarius";
      trusted = true;
      keys = ./keys/raitobezarius;
    }
    {
      name = "networkexception";
      trusted = true;
      keys = ./keys/networkexception;
    }
    {
      name = "pinpox";
      trusted = true;
      keys = ./keys/pinpox;
    }
    {
      name = "perchun";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/perchun;
    }
    {
      # lib.maintainers.pluiedev, https://github.com/pluiedev
      name = "pluiedev";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/pluiedev;
    }
    {
      name = "raboof";
      # lib.maintainers.raboof, https://github.com/raboof
      trusted = true;
      keys = ./keys/raboof;
    }
    {
      # lib.maintainers.rhelmot, https://github.com/rhelmot
      name = "rhelmot";
      trusted = true;
      keys = ./keys/rhelmot;
    }
    {
      # lib.maintainers.sarcasticadmin, https://github.com/sarcasticadmin
      name = "sarcasticadmin";
      trusted = true;
      keys = ./keys/sarcasticadmin;
    }
    {
      name = "schmittlauch";
      trusted = true;
      keys = ./keys/schmittlauch;
    }
    {
      name = "sternenseemann";
      trusted = true;
      keys = ./keys/sternenseemann;
    }
    {
      name = "matthiasbeyer";
      trusted = true;
      keys = ./keys/matthiasbeyer;
    }
    {
      name = "stephank";
      trusted = true;
      keys = ./keys/stephank;
    }
    {
      name = "supinie";
      trusted = true;
      keys = ./keys/supinie;
    }
    {
      name = "teto";
      trusted = true;
      keys = ./keys/teto;
    }
    {
      name = "thecomputerguy";
      trusted = true;
      keys = ./keys/thecomputerguy;
    }
    {
      # lib.maintainers.thefossguy; part of the @NixOS/COSMIC team
      name = "thefossguy";
      trusted = true;
      keys = ./keys/thefossguy;
    }
    {
      name = "tomberek";
      trusted = true;
      keys = ./keys/tomberek;
    }
    {
      name = "tomfitzhenry";
      trusted = true;
      keys = ./keys/tomfitzhenry;
    }
    {
      name = "winter";
      trusted = true;
      keys = ./keys/winter;
    }
    {
      # lib.maintainers.pbsds, https://github.com/pbsds
      name = "pbsds";
      trusted = true;
      keys = ./keys/pbsds;
    }
    {
      name = "matthewcroughan";
      trusted = true;
      keys = ./keys/matthewcroughan;
    }
    {
      name = "emily";
      # lib.maintainers.emily, https://github.com/emilazy
      trusted = true;
      wheel = true;
      keys = ./keys/emily;
    }
    {
      name = "emilylange";
      # lib.maintainers.emilylange, https://github.com/emilylange
      trusted = true;
      keys = ./keys/emilylange;
    }
    {
      name = "doronbehar";
      # lib.maintainers.doronbehar, https://github.com/doronbehar
      trusted = true;
      keys = ./keys/doronbehar;
    }
    {
      name = "fpletz";
      # lib.maintainers.fpletz, https://github.com/fpletz
      trusted = true;
      keys = ./keys/fpletz;
    }
    {
      # lib.maintainers.Enzime, https://github.com/Enzime
      name = "enzime";
      trusted = true;
      keys = ./keys/enzime;
    }
    {
      # lib.maintainers.hexa, https://github.com/mweinelt
      name = "hexa";
      trusted = true;
      keys = ./keys/hexa;
    }
    {
      # lib.maintainers.leona, https://github.com/leona-ya
      name = "leona";
      trusted = true;
      keys = ./keys/leona;
    }
    {
      name = "wolfgangwalther";
      trusted = true;
      keys = ./keys/wolfgangwalther;
    }
    {
      # lib.maintainers.numinit, https://github.com/numinit
      name = "numinit";
      trusted = true;
      keys = ./keys/numinit;
    }
    {
      # lib.maintainers.natsukium, https://github.com/natsukium
      name = "natsukium";
      trusted = true;
      keys = ./keys/natsukium;
    }
    {
      # lib.maintainers.nilp0inter, https://github.com/nilp0inter
      name = "nilp0inter";
      trusted = true;
      keys = ./keys/nilp0inter;
    }
    {
      # lib.maintainers.booxter, https://github.com/booxter
      name = "booxter";
      trusted = true;
      keys = ./keys/booxter;
    }
    {
      # lib.maintainers.lukegb, https://github.com/lukegb
      name = "lukegb";
      trusted = true;
      keys = ./keys/lukegb;
    }
    {
      name = "sinrohit";
      trusted = true;
      keys = ./keys/sinrohit;
    }
    {
      name = "getpsyched";
      trusted = true;
      keys = ./keys/getpsyched;
    }
    {
      # lib.maintainers.HeitorAugustoLN, https://github.com/HeitorAugustoLN
      name = "heitor";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/heitor;
    }
    {
      # lib.maintainers.marie, https://github.com/NyCodeGHG
      name = "marie";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/marie;
    }
    {
      name = "dotlambda";
      trusted = true;
      keys = ./keys/dotlambda;
    }
    {
      # lib.maintainers.zimward, https://github.com/zimward
      name = "zimward";
      trusted = true;
      keys = ./keys/zimward;
    }
    {
      # lib.maintainers.defelo, https://github.com/Defelo
      name = "defelo";
      trusted = true;
      keys = ./keys/defelo;
    }
    {
      # lib.maintainers.kashw2, https://github.com/kashw2
      name = "kashw2";
      trusted = true;
      keys = ./keys/kashw2;
    }
    {
      name = "marcin-serwin";
      # lib.maintainers.marcin-serwin, https://github.com/marcin-serwin
      trusted = true;
      keys = ./keys/marcin-serwin;
    }
    {
      # lib.maintainers.prince213, https://github.com/Prince213
      name = "prince213";
      trusted = true;
      keys = ./keys/prince213;
    }
    {
      # lib.maintainers.mdaniels5757, https://github.com/mdaniels5757
      name = "mdaniels5757";
      trusted = true;
      shell = pkgs.zsh;
      keys = ./keys/mdaniels5757;
    }
    {
      # lib.maintainers.magnetophon, https://github.com/magnetophon
      name = "magnetophon";
      trusted = true;
      shell = pkgs.fish;
      keys = ./keys/magnetophon;
    }
  ];
in
{
  users.users = builtins.listToAttrs (
    builtins.map (u: {
      inherit (u) name;
      value = {
        isNormalUser = true;
        extraGroups = builtins.concatLists [
          (if u ? trusted && u.trusted then [ "trusted" ] else [ ])
          (if u ? wheel && u.wheel then [ "wheel" ] else [ ])
        ];
        home = "/home/${u.name}";
        createHome = true;
        shell = u.shell or config.users.defaultUserShell;
        openssh.authorizedKeys.keyFiles = [ u.keys ];
      };
    }) users
  );
}
