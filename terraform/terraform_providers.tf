terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    hydra = {
      source = "DeterminateSystems/hydra"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}

ephemeral "sops_file" "nix-community" {
  source_file = "secrets.yaml"
}

provider "github" {
  # admin provides their own token
  owner = "nix-community"
}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  password = ephemeral.sops_file.nix-community.data["HYDRA_PASSWORD"]
  username = "admin"
}
