terraform {
  before_hook "reset old terraform state" {
    commands = ["init"]
    execute  = ["rm", "-f", ".terraform.lock.hcl"]
  }
}

generate "terraform" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "remote" {
    organization = "nix-community"
    workspaces { name = "nix-community-${path_relative_to_include()}" }
  }

  required_providers {
    cloudflare = { source = "cloudflare/cloudflare" }
    external   = { source = "hashicorp/external" }
    gandi     = { source = "go-gandi/gandi" }
    hydra     = { source = "DeterminateSystems/hydra" }
    null     = { source = "hashicorp/null" }
    sops   = { source = "carlpett/sops" }
    tfe     = { source = "hashicorp/tfe" }
  }
}
EOF
}
