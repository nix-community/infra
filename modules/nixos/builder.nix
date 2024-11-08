{
  config,
  inputs,
  pkgs,
  ...
}:
{
  nix.gc.automatic = false;

  systemd.services.free-space = {
    serviceConfig.Type = "oneshot";
    startAt = "hourly";
    path = [
      config.nix.package
      pkgs.coreutils
    ];
    script = builtins.readFile "${inputs.self}/modules/shared/free-space.bash";
  };

  # Bump the open files limit so that non-root users can run NixOS VM tests
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "20480";
    }
  ];
}
