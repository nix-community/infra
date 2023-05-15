{ lib, ... }:
{
  options.deploy = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "The user used for deployment via ssh";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "IP addres or host name to connect to the host";
    };
  };
}
