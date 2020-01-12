locals {
  withnix_zone_id = "8fe4b50895da017367d60afd75769bd7"
}

resource "cloudflare_record" "withnix-A" {
  zone_id = local.withnix_zone_id
  name    = "@"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "withnix-www-A" {
  zone_id = local.withnix_zone_id
  name    = "www"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

# Any email coming from that domain are SPAM
resource "cloudflare_record" "withnix-TXT" {
  zone_id = local.withnix_zone_id
  name    = "@"
  value   = "v=spf1 -all"
  type    = "TXT"
}
