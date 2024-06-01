let
  domain = "nix-community.org";
in
{
  zones = {
    "${domain}" = {
      "" = {
        mx.data = [
          {
            exchange = "spool.mail.gandi.net";
            preference = 10;
          }
          {
            exchange = "fb.mail.gandi.net";
            preference = 50;
          }
        ];
        txt.data = "v=spf1 include:_mailcust.gandi.net -all";
      };
      "_github-challenge-nix-community-org".txt.data = "2eee7c1945";
      "_github-pages-challenge-nix-community".txt.data = "6d236784300b9b1e80fdc496b7bfce";
      "darwin01" = {
        a.data = "85.209.53.240";
        aaaa.data = "2a09:9340:808:630::1";
      };
      "darwin02" = {
        a.data = "167.235.38.49";
        aaaa.data = "2a01:4f8:262:24af::1";
      };
      "darwin03" = {
        a.data = "142.132.141.44";
        aaaa.data = "2a01:4f8:261:135a::1";
      };
      "darwin-build-box".cname.data = "darwin01.${domain}";
      "docker".cname.data = "zimbatm.docker.scarf.sh"; # Used by nix-community/nixpkgs-docker
    };
  };
}
