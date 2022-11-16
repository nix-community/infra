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
  }
}

provider "cloudflare" {
  account_id = "e4a2db52c495db230973c839a0699ae1"
}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  username = "admin"
}
