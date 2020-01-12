locals {
  cloudflare_zone_id = "ea3afc8656765143b2d5b7501c243aa7"
}

resource "cloudflare_record" "build01-A" {
  zone_id = local.cloudflare_zone_id
  name    = "build01"
  value   = "94.130.143.84"
  type    = "A"
}

resource "cloudflare_record" "build01-AAAA" {
  zone_id = local.cloudflare_zone_id
  name    = "build01"
  value   = "2a01:4f8:13b:2ceb::1"
  type    = "AAAA"
}

resource "cloudflare_record" "apex-A" {
  zone_id = local.cloudflare_zone_id
  name    = "@"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

# Any email coming from that domain are SPAM
resource "cloudflare_record" "apex-TXT" {
  zone_id = local.cloudflare_zone_id
  name    = "@"
  value   = "v=spf1 -all"
  type    = "TXT"
}
