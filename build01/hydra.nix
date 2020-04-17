{ lib, pkgs, config, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports = [ (import sources.simple-hydra) ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  simple-hydra.enable = true;
  simple-hydra.hostName = "hydra.nix-community.com";
  simple-hydra.useNginx = true;
  simple-hydra.localBuilder = {
    enable = true;
    supportedFeatures = [ "kvm" ];
  };

  services.hydra = {
    enable = true;
    useSubstitutes = true;
    extraConfig = ''
      max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
    '';
  };

  nixpkgs.config = {
    whitelistedLicenses = with lib.licenses; [
      unfreeRedistributable
      issl
    ];

    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "cudnn_cudatoolkit"
      "cudatoolkit"
    ];
  };

  nix = {
    extraOptions = ''
      allowed-uris = https://github.com/nix-community/ https://github.com/NixOS/
    '';
  };
}
