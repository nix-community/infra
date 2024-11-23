locals {
  nix_community_zone_id = "8965c5ff4e19a3ca46b5df6965f2bc36"

  # For each github page, create a CNAME alias to nix-community.github.io
  nix_community_github_pages = [
    "nur"
  ]

  host = {
    "build01" = {
      ipv4 = "65.21.139.242"
      ipv6 = "2a01:4f9:3b:2946::1"
    }
    "build02" = {
      ipv4 = "65.21.133.211"
      ipv6 = "2a01:4f9:3b:41d9::1"
    }
    "build03" = {
      ipv4 = "162.55.14.99"
      ipv6 = "2a01:4f8:2190:2698::2"
    }
    "build04" = {
      ipv4 = "65.109.107.32"
      ipv6 = "2a01:4f9:3051:3962::2"
    }
    "darwin01" = {
      ipv4 = "85.209.53.240"
      ipv6 = "2a09:9340:808:630::1"
    }
    "darwin02" = {
      ipv4 = "85.209.53.203"
      ipv6 = "2a09:9340:808:60b::1"
    }
    "web02" = {
      ipv4 = "46.226.105.188"
      ipv6 = "2001:4b98:dc0:43:f816:3eff:fe99:9fca"
    }
  }

  cname = {
    "alertmanager"        = "web02.nix-community.org"
    "build-box"           = "build01.nix-community.org"
    "buildbot"            = "build03.nix-community.org"
    "darwin-build-box"    = "darwin01.nix-community.org"
    "docker"              = "zimbatm.docker.scarf.sh" # Used by nix-community/nixpkgs-docker
    "grafana"             = "web02.nix-community.org"
    "hydra"               = "build03.nix-community.org"
    "nixpkgs-update-logs" = "build02.nix-community.org"
    "nur-update"          = "build03.nix-community.org"
    "prometheus"          = "web02.nix-community.org"
  }
}

resource "cloudflare_record" "nix-community-org-host-A" {
  for_each = local.host

  zone_id = local.nix_community_zone_id
  name    = each.key
  type    = "A"
  content = each.value.ipv4
}

resource "cloudflare_record" "nix-community-org-host-AAAA" {
  for_each = local.host

  zone_id = local.nix_community_zone_id
  name    = each.key
  type    = "AAAA"
  content = each.value.ipv6
}

resource "cloudflare_record" "nix-community-org-CNAME" {
  for_each = local.cname

  zone_id = local.nix_community_zone_id
  name    = each.key
  content = each.value
  type    = "CNAME"
}

# blocks other CAs from issuing certificates for the domain
resource "cloudflare_record" "nix-community-org-caa" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  type    = "CAA"
  data {
    flags = "0"
    tag   = "issue"
    value = "letsencrypt.org"
  }
}

resource "cloudflare_record" "nix-community-org-apex-A" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  content = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "nix-community-org-apex-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "@"
  content = "v=spf1 include:_mailcust.gandi.net -all"
  type    = "TXT"
}

resource "cloudflare_record" "nix-community-org-apex-MX" {
  for_each = {
    "spool.mail.gandi.net." = 10
    "fb.mail.gandi.net."    = 50
  }
  zone_id  = local.nix_community_zone_id
  name     = "@"
  content  = each.key
  type     = "MX"
  priority = each.value
}

resource "cloudflare_record" "nix-community-org-github-challenge-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "_github-challenge-nix-community-org"
  content = "2eee7c1945"
  type    = "TXT"
}

resource "cloudflare_record" "nix-community-org-github-pages-challenge-TXT" {
  zone_id = local.nix_community_zone_id
  name    = "_github-pages-challenge-nix-community.nix-community.org."
  content = "6d236784300b9b1e80fdc496b7bfce"
  type    = "TXT"
}

resource "cloudflare_record" "nix-community-org-github-pages" {
  for_each = { for page in local.nix_community_github_pages : page => page }

  zone_id = local.nix_community_zone_id
  name    = each.value
  content = "nix-community.github.io"
  type    = "CNAME"
}
