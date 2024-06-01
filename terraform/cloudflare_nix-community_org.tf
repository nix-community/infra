locals {
  nix_community_zone_id = "8965c5ff4e19a3ca46b5df6965f2bc36"

  # For each github page, create a CNAME alias to nix-community.github.io
  nix_community_github_pages = [
    "nur"
  ]
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
  value   = "nix-community.github.io"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "nix-community-org-github-pages" {
  for_each = { for page in local.nix_community_github_pages : page => page }

  zone_id = local.nix_community_zone_id
  name    = each.value
  value   = "nix-community.github.io"
  type    = "CNAME"
}
