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
    }
    {
      name = "stephank";
      trusted = true;
      uid = 503;
    }
    {
      name = "hexa";
      trusted = true;
      uid = 504;
    }
    {
      name = "0x4A6F";
      trusted = true;
      uid = 505;
    }
    {
      name = "artturin";
      trusted = true;
      uid = 506;
    }
    {
      name = "figsoda";
      trusted = true;
      uid = 507;
    }
    {
      name = "raitobezarius";
      trusted = true;
      uid = 508;
    }
    {
      name = "k900";
      trusted = true;
      uid = 509;
    }
    {
      name = "julienmalka";
      trusted = true;
      uid = 510;
    }
    {
      name = "dotlambda";
      trusted = true;
      uid = 511;
    }
    {
      name = "lily";
      trusted = true;
      uid = 512;
    }
    {
      name = "ma27";
      trusted = true;
      uid = 513;
    }
    {
      name = "fab";
      trusted = true;
      uid = 514;
    }
    {
      name = "phaer";
      trusted = true;
      uid = 515;
    }
    {
      name = "emilylange";
      trusted = true;
      uid = 516;
    }
    {
      name = "emilytrau";
      trusted = true;
      uid = 517;
    }
    {
      name = "janik";
      trusted = true;
      uid = 518;
    }
    {
      name = "delroth";
      trusted = true;
      uid = 519;
    }
    {
      name = "toonn";
      trusted = true;
      uid = 520;
    }
    {
      name = "glepage";
      trusted = true;
      uid = 521;
    }
    {
      name = "anthonyroussel";
      trusted = true;
      uid = 522;
    }
    {
      name = "sgo";
      trusted = true;
      uid = 523;
    }
    {
      name = "chayleaf";
      trusted = true;
      uid = 524;
    }
    {
      # https://github.com/lf-
      name = "jade";
      trusted = true;
      uid = 525;
    }
    {
      name = "kranzes";
      trusted = true;
      uid = 526;
    }
    {
      name = "sternenseemann";
      trusted = true;
      uid = 527;
    }
    {
      name = "jtojnar";
      trusted = true;
      uid = 528;
    }
    {
      name = "corngood";
      trusted = true;
      uid = 529;
    }
    {
      name = "teto";
      trusted = true;
      uid = 530;
    }
    {
      name = "matthewcroughan";
      trusted = true;
      uid = 531;
    }
    {
      name = "pennae";
      trusted = true;
      uid = 532;
    }
    {
      name = "jopejoe1";
      trusted = true;
      uid = 533;
    }
    {
      name = "puckipedia";
      trusted = true;
      uid = 534;
    }
    {
      name = "kenji";
      trusted = true;
      uid = 535;
    }
    {
      name = "pinpox";
      trusted = true;
      uid = 536;
    }
    {
      # https://github.com/n0emis
      name = "ember";
      trusted = true;
      uid = 537;
    }
    {
      # lib.maintainers.nicoo, @nbraud on github.com
      name = "nicoo";
      trusted = true;
      uid = 538;
    }
    {
      name = "imincik";
      trusted = true;
      uid = 539;
    }
    {
      name = "wolfgangwalther";
      trusted = true;
      uid = 540;
    }
    {
      name = "tnias";
      trusted = true;
      uid = 541;
    }
    {
      # lib.maintainers.emily, https://github.com/emilazy
      name = "emily";
      trusted = true;
      uid = 542;
    }
    {
      # lib.maintainers.johnrtitor, https://github.com/JohnRTitor
      name = "johnrtitor";
      trusted = true;
      uid = 543;
    }
    {
      # lib.maintainers.kashw2, https://github.com/kashw2
      name = "kashw2";
      trusted = true;
      uid = 544;
    }
    {
      # lib.maintainers.superherointj, https://github.com/superherointj
      name = "superherointj";
      trusted = true;
      uid = 545;
    }
  ];
in
{
  users.users = builtins.listToAttrs (builtins.map
    (u: {
      inherit (u) name;
      value = {
        inherit (u) uid;
        home = "/Users/${u.name}";
        createHome = true;
        shell = "/bin/zsh";
      };
    })
    users);

  users.knownUsers = builtins.map (u: u.name) users;

  users.forceRecreate = true;

  environment.etc = builtins.listToAttrs (builtins.map
    (u: {
      name = "ssh/authorized_keys.d/${u.name}";
      value = { source = ./keys/${u.name}; };
    })
    users);

  nix.settings.trusted-users = builtins.map (u: u.name) (builtins.filter (u: u.trusted) users);
}
