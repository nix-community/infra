terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    hrobot = {
      source = "midwork-finds-jobs/hrobot"
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

provider "hrobot" {
  username = ephemeral.sops_file.nix-community.data["HROBOT_USERNAME"]
  password = ephemeral.sops_file.nix-community.data["HROBOT_PASSWORD"]
}

provider "hydra" {
  host     = "https://hydra.nix-community.org"
  password = ephemeral.sops_file.nix-community.data["HYDRA_PASSWORD"]
  username = "admin"
}
