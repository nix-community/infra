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

  boot.kernelPatches = [
    {
      patch = pkgs.fetchpatch {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/?id=8d09a88ef9d3cb7d21d45c39b7b7c31298d23998";
        hash = "sha256-PCHSnsF0Vrd2nOKbDApyozLu8OUXw/6u6MrGkAWVAYc=";
      };
    }
  ];

}
