locals {
  nix_community_zone_id = "8965c5ff4e19a3ca46b5df6965f2bc36"

  # For each github page, create a CNAME alias to nix-community.github.io
  nix_community_github_pages = [
    "nur"
  ]
}

resource "cloudflare_record" "nix-community-org-build01-A" {
  zone_id = local.nix_community_zone_id
  name    = "build01"
  value   = "94.130.143.84"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build01-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "build01"
  value   = "2a01:4f8:13b:2ceb::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-build02-A" {
  zone_id = local.nix_community_zone_id
  name    = "build02"
  value   = "95.217.109.189"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build02-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "build02"
  value   = "2a01:4f9:4a:2b02::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-build03-A" {
  zone_id = local.nix_community_zone_id
  name    = "build03"
  value   = "135.181.218.169"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build03-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "build03"
  value   = "2a01:4f9:3a:3b16::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-build04-A" {
  zone_id = local.nix_community_zone_id
  name    = "build04"
  value   = "141.148.235.248"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build04-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "build04"
  value   = "2603:c022:c001:b500:66b1:bcc4:3fde:5265"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-darwin01-A" {
  zone_id = local.nix_community_zone_id
  name    = "darwin01"
  value   = "167.235.14.165"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-darwin01-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "darwin01"
  value   = "2a01:4f8:262:1d98::1"
  type    = "AAAA"
}

# Used by nix-community/nixpkgs-docker
resource "cloudflare_record" "nix-community-org-docker-CNAME" {
  zone_id = local.nix_community_zone_id
  name    = "docker"
  value   = "zimbatm.docker.scarf.sh"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-hydra-CNAME" {
  zone_id = local.nix_community_zone_id
  name    = "hydra"
  value   = "build03.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-nur-update-CNAME" {
  zone_id = local.nix_community_zone_id
  name    = "nur-update"
  value   = "build03.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-search-CNAME" {
  zone_id = local.nix_community_zone_id
  name    = "search"
  value   = "build03.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-apex-A" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

# Any email coming from that domain are SPAM
resource "cloudflare_record" "nix-community-org-apex-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  value   = "v=spf1 -all"
  type    = "TXT"
}

resource "cloudflare_record" "nix-community-org-github-challenge-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "_github-challenge-nix-community-org"
  value   = "2eee7c1945"
  type    = "TXT"
}

resource "cloudflare_record" "nix-community-org-github-pages-challenge-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "_github-pages-challenge-nix-community.nix-community.org."
  value   = "6d236784300b9b1e80fdc496b7bfce"
  type    = "TXT"
}

# ehmry's mumble server at vps-free
resource "cloudflare_record" "mumble-A" {
  zone_id = local.nix_community_zone_id
  name    = "mumble"
  value   = "37.205.14.171"
  type    = "A"
}
resource "cloudflare_record" "mumble-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "mumble"
  value   = "2a03:3b40:fe:ab::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-github-pages" {
  for_each = { for page in local.nix_community_github_pages : page => page }

  zone_id = local.nix_community_zone_id
  name    = each.value
  value   = "nix-community.github.io"
  type    = "CNAME"
}
