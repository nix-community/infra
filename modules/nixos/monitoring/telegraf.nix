{
  services.telegraf.extraConfig.inputs = {
    http_response = [
      {
        urls = [ "https://hydra.nix-community.org/" ];
        response_string_match = "hosted on this server";
        tags.host = "build03.nix-community.org";
        tags.org = "nix-community";
      }
      {
        urls = [ "https://lemmy.nix-community.org/" ];
        response_string_match = "Lemmy for Nix";
        tags.host = "web01.nix-community.org";
        tags.org = "nix-community";
      }
      {
        urls = [ "https://nur-update.nix-community.org/" ];
        response_string_match = "NUR update endpoint";
        tags.host = "web01.nix-community.org";
        tags.org = "nix-community";
      }
      {
        urls = [ "https://r.ryantm.com/log/" ];
        response_string_match = "Index of /log/";
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
  };
}
