terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}
