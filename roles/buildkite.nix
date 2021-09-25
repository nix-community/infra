{ pkgs, config, ... }:

{
  sops.secrets.buildkite-token.user = "buildkite-agent-ci";
  sops.secrets.buildkite-agent-key.user = "buildkite-agent-ci";
  sops.secrets.github-nixpkgs-swh-key.user = "buildkite-agent-ci";

  services.buildkite-agents.ci = {
    enable = true;
    tokenPath = config.secrets.buildkite-token.path;
    privateSshKeyPath = config.secrets.buildkite-agent-key.path;
  };
}
