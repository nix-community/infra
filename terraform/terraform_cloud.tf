# Configure Terraform Cloud, with Terraform
#
# Terraform Cloud is used only for one thing: to store the terraform state.
#
locals {
  # FIXME: add all the admins of the org
  # NOTE: there is a limit of 5 members in the free plan
  tfe_owners = {
    zimbatm = "zimbatm@zimbatm.com"
  }

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

# FIXME: I need to find the user ID for my account before this can be used
# resource "tfe_organization_membership" "owners" {
#   for_each     = local.tfe_owners
#   organization = local.tfe_org
#   email        = each.value
# }

# resource "tfe_team_organization_member" "owners" {
#   for_each                   = local.tfe_owners
#   team_id                    = tfe_team.owners.id
#   organization_membership_id = tfe_organization_membership.owners[each.key].id
# }

# Workspaces setup

# For new we only have one workspace that contains everything
resource "tfe_workspace" "nix-community" {
  name           = "nix-community"
  organization   = local.tfe_org
  description    = ""
  execution_mode = "local" # only use it to hold state
}
