terraform {
  backend "remote" {
    organization = "nix-community"
    workspaces { name = "nix-community" }
  }

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    hydra = {
      source = "DeterminateSystems/hydra"
    }
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}

provider "cloudflare" {}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  username = "admin"
}
