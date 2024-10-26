locals {
  cf_account_id = "e4a2db52c495db230973c839a0699ae1"
  cf_roles_by_name = {
    for role in data.cloudflare_account_roles.account_roles.roles :
    role.name => role
  }
  cf_admins = {
    for key, value in local.admins :
    key => value if key != "adisbladis"
  }
}

data "cloudflare_account_roles" "account_roles" {
  account_id = local.cf_account_id
}

resource "cloudflare_account_member" "member" {
  for_each   = local.cf_admins
  account_id = local.cf_account_id
  email      = each.value
  roles = [
    local.cf_roles_by_name["Administrator"].id
  ]
}
