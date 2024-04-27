{
  services.telegraf.extraConfig.inputs = {
    http_response = [
      {
        urls = [ "https://buildbot.nix-community.org/" ];
        response_string_match = "Buildbot Web UI";
        tags.host = "build03.nix-community.org";
        tags.org = "nix-community";
      }
      {
        urls = [ "https://hydra.nix-community.org/" ];
        response_string_match = "hosted on this server";
        tags.host = "build03.nix-community.org";
        tags.org = "nix-community";
      }
      {
        urls = [ "https://nur-update.nix-community.org/" ];
        response_string_match = "NUR update endpoint";
        tags.host = "build03.nix-community.org";
        tags.org = "nix-community";
      }
      {
        urls = [ "https://nixpkgs-update-logs.nix-community.org/~supervisor/" ];
        response_string_match = "state.db";
        tags.host = "build02.nix-community.org";
        tags.org = "nix-community";
      }
    ];
    net_response =
      let
        hosts = import ./hosts.nix;
      in
      map
        (host: {
          protocol = "tcp";
          address = "${host}:22";
          send = "SSH-2.0-Telegraf";
          expect = "SSH-2.0";
          tags.host = host;
          tags.org = "nix-community";
          timeout = "10s";
        })
        hosts;
    prometheus.urls = [
      "https://events.ofborg.org/prometheus.php"
    ];
  };
}
