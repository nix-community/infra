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
      keys = ./keys/perchun;
    }
    {
      name = "raboof";
      # lib.maintainers.raboof, https://github.com/raboof
      trusted = true;
      keys = ./keys/raboof;
    }
    {
      name = "schmittlauch";
      trusted = true;
      keys = ./keys/schmittlauch;
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
      name = "sinrohit";
      trusted = true;
      keys = ./keys/sinrohit;
    }
    {
      name = "getpsyched";
      trusted = true;
      keys = ./keys/getpsyched;
    }
  ];
in
{
  users.users = builtins.listToAttrs (
    builtins.map (u: {
      inherit (u) name;
      value = {
        isNormalUser = true;
        extraGroups = if (u ? trusted && u.trusted) then [ "trusted" ] else [ ];
        home = "/home/${u.name}";
        createHome = true;
        shell = u.shell or config.users.defaultUserShell;
        openssh.authorizedKeys.keyFiles = [ u.keys ];
      };
    }) users
  );
}
