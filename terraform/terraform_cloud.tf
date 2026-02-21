# Configure Terraform Cloud, with Terraform
#
# Terraform Cloud is used only for one thing: to store the terraform state.
#
locals {
  # NOTE: there is a limit of 5 members in the free plan
  tfe_owners = local.admins
}

# Org setup

resource "tfe_organization" "nix-community" {
  name                                = "nix-community"
  email                               = "admin@nix-community.org"
  allow_force_delete_workspaces       = true
  speculative_plan_management_enabled = false
}

# Members setup

resource "tfe_team" "owners" {
  name         = "owners"
  organization = tfe_organization.nix-community.name
}

resource "tfe_organization_membership" "owners" {
  for_each     = local.tfe_owners
  organization = tfe_organization.nix-community.name
  email        = each.value
}

resource "tfe_team_organization_member" "owners" {
  for_each                   = local.tfe_owners
  team_id                    = tfe_team.owners.id
  organization_membership_id = tfe_organization_membership.owners[each.key].id
}

# Project setup

resource "tfe_project" "default" {
  organization = tfe_organization.nix-community.name
  name         = "Default Project"
}

resource "tfe_project_settings" "default-settings" {
  project_id = tfe_project.default.id
  # workspaces in this project will use local execution mode by default
  default_execution_mode = "local" # only use it to hold state
}

# Workspaces setup

# For new we only have one workspace that contains everything
resource "tfe_workspace" "infra" {
  name         = "infra"
  organization = tfe_organization.nix-community.name

  file_triggers_enabled = false
  force_delete          = false
  queue_all_runs        = false
}

resource "tfe_workspace_settings" "infra-settings" {
  workspace_id   = tfe_workspace.infra.id
  execution_mode = "local" # only use it to hold state
}
