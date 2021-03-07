{ pkgs, ... }:

{
  services.buildkite-agents.ci = {
    enable = true;
    tokenPath = "/run/keys/buildkite-token";
    privateSshKeyPath = builtins.toPath "/run/keys/buildkite-agent-key";
  };
}
