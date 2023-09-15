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
  value   = "141.144.201.31"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-build04-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "build04"
  value   = "2603:c022:c001:b500:f1d4:5343:e8ce:d6ba"
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

resource "cloudflare_record" "nix-community-org-darwin02-A" {
  zone_id = local.nix_community_zone_id
  name    = "darwin02"
  value   = "167.235.38.49"
  type    = "A"
}

#resource "cloudflare_record" "nix-community-org-darwin02-AAAA" {
#  zone_id = local.nix_community_zone_id
#  name    = "darwin02"
#  value   = "2001:bc8:a01:3:1698:77ff:fe3a:d38f"
#  type    = "AAAA"
#}

resource "cloudflare_record" "nix-community-org-darwin03-A" {
  zone_id = local.nix_community_zone_id
  name    = "darwin03"
  value   = "142.132.141.44"
  type    = "A"
}

#resource "cloudflare_record" "nix-community-org-darwin03-AAAA" {
#  zone_id = local.nix_community_zone_id
#  name    = "darwin03"
#  value   = "?"
#  type    = "AAAA"
#}

resource "cloudflare_record" "nix-community-org-web01-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "web01"
  value   = "2a01:4f9:c011:932f::1"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-web01-A" {
  zone_id = local.nix_community_zone_id
  name    = "web01"
  value   = "95.216.139.211"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-web02-A" {
  zone_id = local.nix_community_zone_id
  name    = "web02"
  value   = "46.226.105.188"
  type    = "A"
}

resource "cloudflare_record" "nix-community-org-web02-AAAA" {
  zone_id = local.nix_community_zone_id
  name    = "web02"
  value   = "2001:4b98:dc0:43:f816:3eff:fe99:9fca"
  type    = "AAAA"
}

resource "cloudflare_record" "nix-community-org-lemmy-CNAME" {
  zone_id = local.nix_community_zone_id
  name    = "lemmy"
  value   = "web01.nix-community.org"
  type    = "CNAME"
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
  value   = "web01.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-monitoring-CNAME" {
  zone_id = local.nix_community_zone_id
  name    = "monitoring"
  value   = "web02.nix-community.org"
  type    = "CNAME"
}

resource "cloudflare_record" "nix-community-org-apex-A" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "nix-community-org-apex-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  value   = "v=spf1 include:_mailcust.gandi.net -all"
  type    = "TXT"
}

resource "cloudflare_record" "nix-community-org-apex-MX" {
  for_each = {
    "spool.mail.gandi.net." = 10
    "fb.mail.gandi.net."    = 50
  }
  zone_id  = local.nix_community_zone_id
  name     = "@"
  value    = each.key
  type     = "MX"
  priority = each.value
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

resource "cloudflare_record" "nix-community-org-github-pages" {
  for_each = { for page in local.nix_community_github_pages : page => page }

  zone_id = local.nix_community_zone_id
  name    = each.value
  value   = "nix-community.github.io"
  type    = "CNAME"
}
