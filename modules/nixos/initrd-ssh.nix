{ config, ... }:
let
  admins = builtins.filter (user: builtins.elem "wheel" user.extraGroups) (builtins.attrValues config.users.users);
in
{
  boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      # fixme, how can we provide this file on the first installation?
      hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
  boot.initrd.kernelModules = [ "igb" ]; # fixme, this depends on the kernel version
  boot.initrd.network.ssh.authorizedKeyFiles = builtins.concatMap (user: user.openssh.authorizedKeys.keyFiles) admins;

  boot.initrd.systemd.emergencyAccess = "$6$he2fblfl/H7I.kvz$WbSCMXu8ztmqfj5jG4czqvu/rkMHxufxqHgy1urzXFSN.jZB4QiW5lOjR08vk8pZTyim3TT1wFkMaNE9zZ3sc1";
}
