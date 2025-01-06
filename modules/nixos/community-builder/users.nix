{ config, pkgs, ... }:
let
  users = [
    # 1. Generate an SSH key for your root account and add the public
    #    key to a file matching your name in ./keys/
    #
    # 2. Copy / paste this in order, alphabetically:
    #
    #    youruser.keys = ./keys/youruser;
    #
    {
      name = "0x4A6F";
      trusted = true;
      keys = ./keys/0x4A6F;
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
      name = "jtojnar";
      trusted = true;
      keys = ./keys/jtojnar;
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
      name = "winter";
      trusted = true;
      keys = ./keys/winter;
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
