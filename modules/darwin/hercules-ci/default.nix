{ inputs, pkgs, ... }:
{
  # hercules secrets are installed manually from ./secrets.yaml
  # https://docs.hercules-ci.com/hercules-ci/getting-started/deploy/nix-darwin
  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.package = inputs.hercules-ci-agent.packages.${pkgs.stdenv.hostPlatform.system}.hercules-ci-agent;
}
