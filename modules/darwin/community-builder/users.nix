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
      uid = 510;
    }
    {
      name = "julienmalka";
      trusted = true;
      uid = 511;
    }
    {
      name = "dotlambda";
      trusted = true;
      uid = 512;
    }
    {
      name = "lily";
      trusted = true;
      uid = 513;
    }
    {
      name = "ma27";
      trusted = true;
      uid = 514;
    }
    {
      name = "fab";
      trusted = true;
      uid = 515;
    }
    {
      name = "phaer";
      trusted = true;
      uid = 516;
    }
    {
      name = "emilylange";
      trusted = true;
      uid = 517;
    }
    {
      name = "emilytrau";
      trusted = true;
      uid = 518;
    }
    {
      name = "janik";
      trusted = true;
      uid = 519;
    }
    {
      name = "delroth";
      trusted = true;
      uid = 520;
    }
    {
      name = "toonn";
      trusted = true;
      uid = 542;
    }
    {
      name = "glepage";
      trusted = true;
      uid = 543;
    }
    {
      name = "anthonyroussel";
      trusted = true;
      uid = 544;
    }
    {
      name = "sgo";
      trusted = true;
      uid = 545;
    }
    {
      name = "chayleaf";
      trusted = true;
      uid = 546;
    }
    {
      # https://github.com/lf-
      name = "jade";
      trusted = true;
      uid = 547;
    }
    {
      name = "kranzes";
      trusted = true;
      uid = 548;
    }
    {
      name = "sternenseemann";
      trusted = true;
      uid = 549;
    }
    {
      name = "jtojnar";
      trusted = true;
      uid = 550;
    }
    {
      name = "corngood";
      trusted = true;
      uid = 551;
    }
    {
      name = "teto";
      trusted = true;
      uid = 552;
    }
    {
      name = "matthewcroughan";
      trusted = true;
      uid = 553;
    }
    {
      name = "pennae";
      trusted = true;
      uid = 554;
    }
    {
      name = "jopejoe1";
      trusted = true;
      uid = 555;
    }
    {
      name = "puckipedia";
      trusted = true;
      uid = 556;
    }
    {
      name = "kenji";
      trusted = true;
      uid = 557;
    }
    {
      name = "annalee";
      trusted = true;
      uid = 558;
    }
    {
      name = "pinpox";
      trusted = true;
      uid = 559;
    }
    {
      # https://github.com/n0emis
      name = "ember";
      trusted = true;
      uid = 560;
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
