{ config, ... }:
{
  sops.secrets."binary-caches.json".owner = "hercules-ci-agent";
  sops.secrets."cluster-join-token.key".owner = "hercules-ci-agent";

  services.hercules-ci-agent = {
    enable = true;
    # For some reason it wants a directory, and looks for specific filenames
    # in there.
    settings.staticSecretsDirectory =
      builtins.dirOf config.sops.secrets."cluster-join-token.key".path;
  };
}
