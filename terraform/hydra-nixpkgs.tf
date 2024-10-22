locals {
  jobset = {
    cuda = {
      name                 = "cuda"
      description          = "Testing CUDA support. Come help the CUDA team! https://nixos.org/community/teams/cuda/"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
    }
    cuda_stable = {
      name                 = "cuda-stable"
      description          = "Testing CUDA support. Come help the CUDA team! https://nixos.org/community/teams/cuda/"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-24.05-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
    }
    rocm = {
      name                 = "rocm"
      description          = "Testing ROCm support."
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
      variant              = "rocm"
    }
  }
}

resource "hydra_jobset" "nixpkgs_jobset" {
  for_each = local.jobset

  project     = hydra_project.nixpkgs.name
  state       = "enabled"
  visible     = true
  name        = each.value.name
  type        = "legacy"
  description = each.value.description

  nix_expression {
    file  = each.value.nixpkgs_release_file
    input = "nixpkgs"
  }

  input {
    name              = "nixpkgs"
    type              = "git"
    value             = each.value.nixpkgs_channel
    notify_committers = false
  }

  dynamic "input" {
    for_each = [for variant in [lookup(each.value, "variant", null)] : variant if variant != null]

    content {
      name              = "variant"
      type              = "string"
      value             = input.value
      notify_committers = false
    }
  }

  input {
    name              = "officialRelease"
    type              = "boolean"
    value             = "false"
    notify_committers = false
  }

  input {
    name              = "supportedSystems"
    type              = "nix"
    value             = each.value.supported_systems
    notify_committers = false
  }

  check_interval    = 1800
  scheduling_shares = each.value.scheduling_shares
  keep_evaluations  = 1

  email_notifications = false
  email_override      = ""
}

resource "hydra_project" "nixpkgs" {
  name         = "nixpkgs"
  display_name = "nixpkgs"
  description  = "you know what this is"
  homepage     = "https://github.com/NixOS/nixpkgs"
  owner        = "admin"
  enabled      = true
  visible      = true
}
