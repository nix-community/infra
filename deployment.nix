let

  secrets = import ./secrets;

in
{

  network.description = "nix-community infra";

  build01 =
    { resources, ... }:
      {
        imports = [
          ./build01/configuration.nix
        ];

        deployment.targetHost = "94.130.143.84";

        deployment.keys.buildkite-token = {
          text = secrets.buildkite-token;
          user = "buildkite-agent";
          permissions = "0600";
        };

        deployment.keys.buildkite-agent-key = {
          text = secrets.buildkite-agent-key;
          user = "buildkite-agent";
          permissions = "0600";
        };

        deployment.keys."buildkite-agent-key.pub" = {
          text = secrets."buildkite-agent-key.pub";
          user = "buildkite-agent";
          permissions = "0600";
        };

        deployment.keys.gitlab-runner-registration = {
          text = secrets.gitlab-runner-registration;
          user = "gitlab-runner";
          permissions = "0600";
        };

        deployment.keys."id_rsa" = {
          text = secrets.github-r-ryantm-key;
          destDir = "/home/r-ryantm/.ssh";
          user = "r-ryantm";
          group = "r-ryantm";
          permissions = "0600";
        };

        deployment.keys."github_token.txt" = {
          text = secrets.github-r-ryantm-token;
          destDir = "/var/lib/nixpkgs-update";
          user = "r-ryantm";
          group = "r-ryantm";
          permissions = "0600";
        };

        deployment.keys."github_token_with_username.txt" = {
          text = "r-ryantm:${secrets.github-r-ryantm-token}";
          destDir = "/var/lib/nixpkgs-update";
          user = "r-ryantm";
          group = "r-ryantm";
          permissions = "0600";
        };

        deployment.keys."cachix.dhall" = {
          text = secrets."cachix.dhall";
          destDir = "/var/lib/nixpkgs-update/cachix";
          user = "r-ryantm";
          group = "r-ryantm";
          permissions = "0600";
        };

        deployment.keys.github-nixpkgs-swh-key = {
          text = secrets.github-nixpkgs-swh-key;
          user = "buildkite-agent";
          permissions = "0400";
        };
      };

}
