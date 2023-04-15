locals {
  user = "nix-community"
  blacklist = [
    # invalid name
    ".github",
    # do already exists
    "emacs-overlay",
    "docker-nixpkgs",
    "nixos-generators",
    "poetry2nix",
  ]
  # remove blacklist
  filteredRepos = [
    for repo in data.github_repositories.repos.full_names : repo if !contains(local.blacklist, element(split("/", repo), 1))
  ]
}

data "github_repositories" "repos" {
  query = "user:${local.user} is:public"
}

data "github_repositories" "non-archived-repos" {
  query = "user:${local.user} is:public archived:false"
}

resource "gitlab_group" "group" {
  name             = local.user
  path             = local.user
  visibility_level = "public"
}

resource "gitlab_project" "repos" {
  for_each               = toset(local.filteredRepos)
  name                   = element(split("/", each.key), 1)
  namespace_id           = gitlab_group.group.id
  import_url             = "https://github.com/${each.key}"
  shared_runners_enabled = false
  visibility_level       = "public"
}

# Cannot use api here or we run into api rate limits.
data "external" "repos" {
  for_each = toset(local.filteredRepos)
  program  = ["bash", "./get-last-commit.sh", each.key]
}

# update gitlab repo if github repo has new commits
resource "null_resource" "update-repo" {
  for_each = toset(local.filteredRepos)
  triggers = {
    last_commit = data.external.repos[each.key].result.last_commit
  }
  provisioner "local-exec" {
    environment = {
      REPO = each.key
    }
    command = "bash ./update-repo.sh"
  }
}
