terraform {
  backend "remote" {
    organization = "nix-community"
    workspaces { name = "nix-community" }
  }
}
