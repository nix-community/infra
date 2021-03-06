locals {
  nix_community_org_zone_id = "8965c5ff4e19a3ca46b5df6965f2bc36"
}

resource "cloudflare_record" "nix-community-org-build01-A" {
  zone_id = local.nix_community_org_zone_id
  name    = "build01"
  value   = "94.130.143.84"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build01-AAAA" {
  zone_id = local.nix_community_org_zone_id
  name    = "build01"
  value   = "2a01:4f8:13b:2ceb::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-build02-A" {
  zone_id = local.nix_community_org_zone_id
  name    = "build02"
  value   = "95.217.109.189"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build02-AAAA" {
  zone_id = local.nix_community_org_zone_id
  name    = "build02"
  value   = "2a01:4f9:4a:2b02::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-build03-A" {
  zone_id = local.nix_community_org_zone_id
  name    = "build03"
  value   = "135.181.218.169"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build03-AAAA" {
  zone_id = local.nix_community_org_zone_id
  name    = "build03"
  value   = "2a01:4f9:3a:3b16::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-hydra-CNAME" {
  zone_id = local.nix_community_org_zone_id
  name    = "hydra"
  value   = "build01.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-search-CNAME" {
  zone_id = local.nix_community_org_zone_id
  name    = "search"
  value   = "build01.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-apex-A" {
  zone_id = local.nix_community_org_zone_id
  name    = "@"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

# Any email coming from that domain are SPAM
resource "cloudflare_record" "nix-community-org-apex-TXT" {
  zone_id = local.nix_community_org_zone_id
  name    = "@"
  value   = "v=spf1 -all"
  type    = "TXT"
}

# ehmry's mumble server at vps-free
resource "cloudflare_record" "mumble-A" {
  zone_id = local.nix_community_org_zone_id
  name    = "mumble"
  value   = "37.205.14.171"
  type    = "A"
}
resource "cloudflare_record" "mumble-AAAA" {
  zone_id = local.nix_community_org_zone_id
  name    = "mumble"
  value   = "2a03:3b40:fe:ab::1"
  type    = "AAAA"
}

# For each github page, create a CNAME alias to nix-community.github.io
locals {
  github_pages = [
    "nur"
  ]
}

resource "cloudflare_record" "nix-community-org-github-pages" {
  for_each = {for page in local.github_pages: page => page}

  zone_id = local.nix_community_org_zone_id
  name    = each.value
  value   = "nix-community.github.io"
  type    = "CNAME"
}
