locals {
  jobset = {
    cuda = {
      name                 = "cuda"
      description          = "nixos-unstable-small cuda"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      check_interval       = 1800
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
    }
    cuda_stable = {
      name                 = "cuda-stable"
      description          = "nixos-24.11-small cuda"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-24.11-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      check_interval       = 1800
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
    }
    cuda_stable_previous = {
      name                 = "cuda-stable-previous"
      description          = "nixos-24.05-small cuda"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-24.05-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      check_interval       = 1800
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
    }
    rocm = {
      name                 = "rocm"
      description          = "nixos-unstable-small rocm"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      nixpkgs_release_file = "pkgs/top-level/release-cuda.nix"
      check_interval       = 1800
      scheduling_shares    = 6000
      supported_systems    = "[ \"x86_64-linux\" ]"
      variant              = "rocm"
    }
    unfree_redist = {
      name                 = "unfree-redist"
      description          = "nixos-unstable-small unfree+redistributable"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      nixpkgs_release_file = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval       = 1800
      scheduling_shares    = 5000
      supported_systems    = "[ \"aarch64-linux\" \"x86_64-linux\" ]"
    }
    unfree_redist_darwin = {
      name                 = "unfree-redist-darwin"
      description          = "nixpkgs-unstable darwin unfree+redistributable"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixpkgs-unstable"
      nixpkgs_release_file = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval       = 1800
      scheduling_shares    = 5000
      supported_systems    = "[ \"aarch64-darwin\" \"x86_64-darwin\" ]"
    }
    unfree_redist_full = {
      name                 = "unfree-redist-full"
      description          = "nixos-unstable unfree+redistributable full"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-unstable"
      nixpkgs_release_file = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval       = 604800
      scheduling_shares    = 1000
      supported_systems    = "[ \"x86_64-linux\" ]"
      full                 = "true"
    }
    unfree_redist_stable = {
      name                 = "unfree-redist-stable"
      description          = "nixos-24.11-small unfree+redistributable"
      nixpkgs_channel      = "https://github.com/NixOS/nixpkgs.git nixos-24.11-small"
      nixpkgs_release_file = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval       = 1800
      scheduling_shares    = 5000
      supported_systems    = "[ \"aarch64-linux\" \"x86_64-linux\" ]"
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
    for_each = [for full in [lookup(each.value, "full", null)] : full if full != null]

    content {
      name              = "full"
      type              = "boolean"
      value             = input.value
      notify_committers = false
    }
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

  check_interval    = each.value.check_interval
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
