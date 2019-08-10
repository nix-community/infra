{ pkgs, ...}:

{
  services.buildkite-agent = {
    enable = true;
    tokenPath = "/run/keys/buildkite-token";
    openssh.privateKeyPath = builtins.toPath "/run/keys/buildkite-agent-key";
    openssh.publicKeyPath = builtins.toPath "/run/keys/buildkite-agent-key-pub";
  };
}
