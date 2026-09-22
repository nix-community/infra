terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    hydra = {
      source = "DeterminateSystems/hydra"
    }
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}

provider "github" {
  # admin provides their own token
  owner = "nix-community"
}

variable "hydra_admin_password" {
  ephemeral = true
  sensitive = true
}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  password = var.hydra_admin_password
  username = "admin"
}
