{ config, pkgs, lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGB1Pog97SWdV2UEA40V+3bML+lSZXEd48zCRlS/eGbY3rsXfgUXb5FIBulN9cET9g0OOAKeCZBR1Y2xXofiHDYkhk298rHDuir6cINuoMGUO7VsygUfKguBy63QMPHYnJBE1h+6sQGu/3X9G2o/0Ys2J+lZv4+N7Hqolhbg/Cu6/LUCsJM/udqTVwJGEqszDWPtuuTAIS6utB1QdL9EZT5WBb1nsNyHnIlCnoDKZvrrO9kM0FGKhjJG2skd3+NqmLhYIDhRhZvRnL9c8U8uozjbtj/N8L/2VCRzgzKmvu0Y1cZMWeAAdyqG6LoyE7xGO+SF4Vz1x6JjS9VxnZipIB"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxiMI0QgaxBTRgzhCtgiyFEcRiZ7SH6LC0byweSlThcpevN6W8ZQZFqv9BhEmq/Hukrgytm8WkdYHCWWRdDcC94AUHxNG+wF4ONLUaX+xpuuwd6KQVHAOZ9kDyPNdXIO9Ad6YiqiVD4fI4wi9wl/hBQQgB7jF+BKPjOfoE2D95psyEqFcD13mlFQAMZnPzYVSv72uWu4Cf6ft4XbrMeqxa71TIoEsjlZ+BVOg+mVmfZNtThtwJ1FZ+tEX6pwFGNAacZWx4TZmPojZaauwBmTJDC5DKgPH4ZmejIgCerjIUsjmNcRXNRinKitWpaV3KIAPc+lrNZPB4I3lmKuW5uFQr"
  ];

in
{
  users.users.zimbatm = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "zimb";
  };
}
