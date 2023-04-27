terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    gandi = {
      source = "go-gandi/gandi"
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

provider "gandi" {
  key        = data.sops_file.nix-community.data["GANDI_KEY"]
  sharing_id = data.sops_file.nix-community.data["GANDI_SHARING_ID"]
}

provider "github" {
  owner = "nix-community"
  token = data.sops_file.secrets.data["GITHUB_TOKEN"]
}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  password = data.sops_file.nix-community.data["HYDRA_PASSWORD"]
  username = "admin"
}

provider "tfe" {
  token = data.sops_file.nix-community.data["TFE_TOKEN"]
}
