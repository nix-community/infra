{ inputs, ... }:
{
  nixpkgs.overlays = [ inputs.hydra.overlays.default ];

  services.hydra-queue-builder-dev = {
    enable = true;
    authorizationFile = "/mnt/secrets/hydra-token";
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
  };
}
