{ pkgs, config, ... }:

{
  sops.secrets.buildkite-token.owner = "buildkite-agent-ci";
  sops.secrets.buildkite-agent-key.owner = "buildkite-agent-ci";
  sops.secrets.github-nixpkgs-swh-key.owner = "buildkite-agent-ci";

  services.buildkite-agents.ci = {
    enable = true;
    tokenPath = config.sops.secrets.buildkite-token.path;
    privateSshKeyPath = config.sops.secrets.buildkite-agent-key.path;
  };
}
