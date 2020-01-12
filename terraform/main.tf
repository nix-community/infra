terraform {
  backend "remote" {
    organization = "nix-community"
    workspaces { name = "nix-community" }
  }
}

provider "cloudflare" {
  version    = "~> 2.0"
  account_id = "e4a2db52c495db230973c839a0699ae1"
}
