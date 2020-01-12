locals {
  builtwithnix_zone_id = "90161b6fed8644e4f5ea1eb8535260b1"
}

resource "cloudflare_record" "builtwithnix-A" {
  zone_id = local.builtwithnix_zone_id
  name    = "@"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "builtwithnix-www-A" {
  zone_id = local.builtwithnix_zone_id
  name    = "www"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

# Any email coming from that domain are SPAM
resource "cloudflare_record" "builtwithnix-TXT" {
  zone_id = local.builtwithnix_zone_id
  name    = "@"
  value   = "v=spf1 -all"
  type    = "TXT"
}
