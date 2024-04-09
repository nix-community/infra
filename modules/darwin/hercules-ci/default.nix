{ config, pkgs, ... }:
let
  securityWrapper = pkgs.writeScriptBin "security" ''
    exec /usr/bin/security "$@"
  '';
in
{
  # hercules secrets are installed manually from ./secrets.yaml
  # https://docs.hercules-ci.com/hercules-ci/getting-started/deploy/nix-darwin
  services.hercules-ci-agent.enable = true;

  # hercules-ci-agent: security: createProcess: posix_spawnp: does not exist
  # https://github.com/LnL7/nix-darwin/blob/36524adc31566655f2f4d55ad6b875fb5c1a4083/modules/services/hercules-ci-agent/default.nix#L28
  launchd.daemons.hercules-ci-agent.path = pkgs.lib.mkForce [ config.nix.package securityWrapper ];
}
