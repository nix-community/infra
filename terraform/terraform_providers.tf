terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    github = {
      source = "integrations/github"
    }
    hydra = {
      source = "DeterminateSystems/hydra"
    }
    sops = {
      source = "carlpett/sops"
    }
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}

data "sops_file" "nix-community" {
  source_file = "secrets.yaml"
}

provider "cloudflare" {
  api_token = data.sops_file.nix-community.data["CLOUDFLARE_API_TOKEN"]
}

provider "github" {
  # admin provides their own token
  owner = "nix-community"
}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  password = data.sops_file.nix-community.data["HYDRA_PASSWORD"]
  username = "admin"
}

provider "tfe" {
  token = data.sops_file.nix-community.data["TFE_TOKEN"]
}
