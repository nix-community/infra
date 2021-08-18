terraform {
  backend "remote" {
    organization = "nix-community"
    workspaces { name = "nix-community" }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
}

provider "cloudflare" {
  account_id = "e4a2db52c495db230973c839a0699ae1"
}
