{ inputs, lib, ... }:
{
  job_name = "telegraf";
  scrape_interval = "60s";
  metrics_path = "/metrics";
  static_configs =
    let
      hosts = (import "${inputs.self}/modules/shared/known-hosts.nix").programs.ssh.knownHosts;
    in
    [
      {
        targets =
          builtins.concatMap (host: map (name: "${name}:9273") host.hostNames) (builtins.attrValues hosts)
          ++ map (name: "${lib.removeSuffix "-freebsd" name}.nix-community.org:39273") (
            builtins.attrNames inputs.self.nixbsdConfigurations
          );
        labels.org = "nix-community";
      }
    ];
}
