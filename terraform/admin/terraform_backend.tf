terraform {
  backend "remote" {
    organization = "nix-community"
    workspaces { name = "admin" }
  }
}
