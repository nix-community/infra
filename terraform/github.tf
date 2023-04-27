resource "github_membership" "owners" {
  # make the bot an org owner but don't add it to the admin team
  for_each = merge(local.admins, local.bot)
  username = each.key
  role     = "admin"
}

resource "github_team" "admin" {
  name        = "admin"
  description = "Organisation owners and people who have access to the infrastructure"
  privacy     = "closed"
}

resource "github_team_membership" "admin" {
  for_each = local.admins
  role     = "maintainer"
  team_id  = github_team.admin.id
  username = each.key
}
