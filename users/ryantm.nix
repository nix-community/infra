{ config, pkgs, lib, ... }:

let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5KESKmapziCEd05LPnW1Ib+t5N18aZ8nzeVSZ3w79vGZHacgwKrGAQkQ1JbEFsm1aXQ4LR27l7Y5MM+auf0YZdGjtAiSsV/G/mjBP95HsuFTE1NSsXisdyKBkJ1g8TUfNOq2gsFyUVCeLMz4fC/ZYxdfBRpPnA6lCblWPmwLAaKTuI7afLv9UGN36/lFKReFzLpMfjYu/HAOYglRuQr8UcYvuysfDKwHImZYdZbzId2pg52nntSAiRgavjt2StiXVQz8zrCtvkguAkG6R8ZSPDyIJ0gLPNLxryIVLPscRbmH0usr3ipemOEplIsiNwp9pW2AQj0jZMBA55T75jxW2Q== ryantm-personal"
  ];

in {
  users.users.ryantm = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    uid = userLib.mkUid "rytm";
  };

  nix.trustedUsers = [
    "ryantm"
  ];

}
