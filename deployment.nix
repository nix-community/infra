with builtins;
let
  secrets = import ./secrets.nix;

  # Copied from <nixpkgs/lib>
  removeSuffix = suffix: str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if
      sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str
    then
      substring 0 (sLen - sufLen) str
    else
      str;

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
        text = removeSuffix "\n" secrets.buildkite-token;
        user = "buildkite-agent-ci";
        permissions = "0600";
      };

      deployment.keys.buildkite-agent-key = {
        text = secrets.buildkite-agent-key;
        user = "buildkite-agent-ci";
        permissions = "0600";
      };

      deployment.keys."buildkite-agent-key.pub" = {
        text = secrets."buildkite-agent-key.pub";
        user = "buildkite-agent-ci";
        permissions = "0600";
      };

      deployment.keys.gitlab-runner-registration = {
        text = secrets.gitlab-runner-registration;
        user = "gitlab-runner";
        permissions = "0600";
      };

      deployment.keys."marvin-mk2-key.pem" = {
        text = secrets."marvin-mk2-key.pem";
        destDir = "/var/lib/marvin-mk2";
        user = "marvin-mk2";
        group = "marvin-mk2";
        permissions = "0600";
      };

      deployment.keys."marvin_mk2_id.txt" = {
        text = secrets."marvin_mk2_id.txt";
        destDir = "/var/lib/marvin-mk2";
        user = "marvin-mk2";
        group = "marvin-mk2";
        permissions = "0600";
      };

      deployment.keys."marvin-mk2-webhook-secret.txt" = {
        text = secrets."marvin-mk2-webhook-secret.txt";
        destDir = "/var/lib/marvin-mk2";
        user = "marvin-mk2";
        group = "marvin-mk2";
        permissions = "0600";
      };

      deployment.keys."matterbridge.toml" = {
        text = secrets."matterbridge.toml";
        user = "matterbridge";
        group = "matterbridge";
        permissions = "0400";
      };

      deployment.keys."nix-community-cachix.dhall" = {
        text = secrets."nix-community-cachix.dhall";
        destDir = "/var/lib/post-build-hook";
        user = "root";
        permissions = "0400";
      };

      deployment.keys.github-nixpkgs-swh-key = {
        text = secrets.github-nixpkgs-swh-key;
        user = "buildkite-agent-ci";
        permissions = "0400";
      };

      deployment.keys.hydra-admin-password = {
        text = secrets.hydra-admin-password;
        user = "hydra";
        permissions = "0400";
      };

    };

  build02 =
    { resources, ... }:
    {
      imports = [
        ./build02/configuration.nix
      ];

      deployment.targetHost = "95.217.109.189";

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

      deployment.keys."nix-community-cachix.dhall" = {
        text = secrets."nix-community-cachix.dhall";
        destDir = "/var/lib/post-build-hook";
        user = "root";
        permissions = "0400";
      };

    };

  build03 =
    { resources, ... }:
    {
      imports = [
        ./build03/configuration.nix
      ];

      deployment.targetHost = "build03.nix-community.org";
    };
}
