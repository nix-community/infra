{ inputs, ... }:
{
  imports = [
    (import "${inputs.hydra}/nixos-modules/ad-hoc-module.nix")
  ];

  services.hydra-ad-hoc-dev = {
    enable = true;
  };
}
