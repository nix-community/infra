{ config, pkgs, lib, ... }:

let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnYBizOiLe2Lb88vdrehrmJiSvVxdRxKWmK/xBzPSuyw1J71Y38dNfGraDcsQtVmysAE+KKPgw6UXX7nl3pQZOe78s0WfKFG8cC1HVQE6RUhipLsml4bLupWcRuJUnKXjuaIvs6vCeroSrmkKWgcGdE2lgb6eMNB7ehXTzQY47st8SpW7wuqQ8BaXlMb1fKNFW8DJB9XqoMQnFiFVQSsTz8R6Tu8T3CWNNcsMwfKBCcbnsr60EgexOVgSMtDAIoIBHPM1o131ImKtoldZ4JpB5ZkrHKF3EbBmPLX4SJwxmo3q1vTF9KM6UnWA6MT5vtoMOeqbz5eeq1QXBIcZN12eX root@mvp-nixos"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKkESghka5dtI5CG+woTl+we5c5VVnmzF9QUkGSH/+LDDIY/uQWViXTOhmc2vhFtvBaX4dqJrQLJNObUJmu1WIaKQmPDPWPWL8DQVRIB80xiiW7zWyM9ym2JcKtn3Go8c2VM2x0orycchOGfclx2sI0eA/d2ehyxdRh2S/VPw3GkhIfjFreDFKvCORwFZCqwbRJ4TgJ9la4p8TcQpZc6ZjNf7SRq2KCS+sB6J+XhUgh+SN8JKIKW0xmINn+jMtRTORBXePKajoBmETPrQ0D0LcL+QlG0Pq+qRqfKWxSdh0eBM4T6Vj/okO0Ngf1FccEh5gD4gLJxX5NMyor4NfhROn kiwi@mbp.local"
  ];

in {
  users.users.kiwi = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    uid = userLib.mkUid "kiwi";
  };

  nix.trustedUsers = [
    "kiwi"
  ];

}
