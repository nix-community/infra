# FIXME: Not declared because needs the owners block and so would require us
# to expose personal mail addresses to the public.
#
# resource "gandi_domain" "nix_community" {
#   name = "nix-community.org"
# }

resource "gandi_email_forwarding" "admin" {
  source       = "admin@nix-community.org"
  destinations = values(local.admins)
}
