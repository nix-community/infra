# Configure Terraform Cloud, with Terraform
#
# Terraform Cloud is used only for one thing: to store the terraform state.
#
locals {
  # NOTE: there is a limit of 5 members in the free plan
  tfe_owners = local.admins

  tfe_org = "nix-community" #tfe_organization.nix-community.name
}

# Org setup
# FIXME: import is broken
# resource "tfe_organization" "nix-community" {
#   name = "nix-community"
#   # FIXME: host our own email. See https://github.com/nix-community/infra/issues/393
#   email = "nix-community@numtide.com"
# }

# Members setup

resource "tfe_team" "owners" {
  name         = "owners"
  organization = "nix-community"
}

resource "tfe_organization_membership" "owners" {
  for_each     = local.tfe_owners
  organization = local.tfe_org
  email        = each.value
}

resource "tfe_team_organization_member" "owners" {
  for_each                   = local.tfe_owners
  team_id                    = tfe_team.owners.id
  organization_membership_id = tfe_organization_membership.owners[each.key].id
}

# Workspaces setup

resource "tfe_workspace" "admin" {
  name           = "admin"
  organization   = local.tfe_org
  description    = ""
  execution_mode = "local" # only use it to hold state
}

resource "tfe_workspace" "nix-community" {
  name           = "nix-community"
  organization   = local.tfe_org
  description    = ""
  execution_mode = "local" # only use it to hold state
}
