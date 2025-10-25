locals {
  stable          = "25.11"
  stable_previous = "25.05"

  jobset = {
    armv7l-linux = {
      name              = "armv7l-linux"
      description       = "nixos-unstable-small armv7l-linux"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      release_file      = "hydra/armv7l-linux.nix"
      check_interval    = 1800
      scheduling_shares = 1000
      supported_systems = ["armv7l-linux"]
      release_source    = "https://github.com/nix-community/infra.git master"
    }
    bsd = {
      name              = "bsd"
      description       = "nixos-unstable-small bsd"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      release_file      = "hydra/bsd.nix"
      check_interval    = 1800
      scheduling_shares = 1000
      supported_systems = ["x86_64-freebsd"]
      release_source    = "https://github.com/nix-community/infra.git master"
    }
    bsd_staging_next = {
      name              = "bsd-staging-next"
      description       = "staging-next bsd"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git staging-next"
      release_file      = "hydra/bsd.nix"
      check_interval    = 1800
      scheduling_shares = 1000
      supported_systems = ["x86_64-freebsd"]
      release_source    = "https://github.com/nix-community/infra.git master"
    }
    cuda_stable = {
      name              = "cuda-stable"
      description       = "nixos-25.05-small cuda"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-25.05-small"
      release_file      = "pkgs/top-level/release-cuda.nix"
      check_interval    = 1800
      scheduling_shares = 6000
      supported_systems = ["x86_64-linux"]
    }
    unfree_redist = {
      name              = "unfree-redist"
      description       = "nixos-unstable-small unfree+redistributable"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
      release_file      = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval    = 1800
      scheduling_shares = 5000
      supported_systems = ["aarch64-linux", "x86_64-linux"]
    }
    unfree_redist_full = {
      name              = "unfree-redist-full"
      description       = "nixos-unstable unfree+redistributable full"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-unstable"
      release_file      = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval    = 1800
      scheduling_shares = 1000
      supported_systems = ["x86_64-linux"]
      full              = "true"
    }
    unfree_redist_stable = {
      name              = "unfree-redist-stable"
      description       = "nixos-${local.stable}-small unfree+redistributable"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-${local.stable}-small"
      release_file      = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval    = 1800
      scheduling_shares = 5000
      supported_systems = ["aarch64-linux", "x86_64-linux"]
    }
    unfree_redist_stable_previous = {
      name              = "unfree-redist-stable-previous"
      description       = "nixos-${local.stable_previous}-small unfree+redistributable"
      nixpkgs_channel   = "https://github.com/NixOS/nixpkgs.git nixos-${local.stable_previous}-small"
      release_file      = "pkgs/top-level/release-unfree-redistributable.nix"
      check_interval    = 1800
      scheduling_shares = 5000
      supported_systems = ["aarch64-linux", "x86_64-linux"]
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
    file  = each.value.release_file
    input = lookup(each.value, "release_source", null) != null ? "release_source" : "nixpkgs"
  }

  dynamic "input" {
    for_each = lookup(each.value, "release_source", null) != null ? [each.value.release_source] : []

    content {
      name              = "release_source"
      type              = "git"
      value             = input.value
      notify_committers = false
    }
  }

  input {
    name              = "nixpkgs"
    type              = "git"
    value             = each.value.nixpkgs_channel
    notify_committers = false
  }

  dynamic "input" {
    for_each = lookup(each.value, "full", null) != null ? [each.value.full] : []

    content {
      name              = "full"
      type              = "boolean"
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
    value             = "[ ${join(" ", formatlist("\"%s\"", each.value.supported_systems))} ]"
    notify_committers = false
  }

  check_interval    = each.value.check_interval
  scheduling_shares = each.value.scheduling_shares
  keep_evaluations  = 1

  email_notifications = false
  email_override      = ""

  lifecycle { ignore_changes = [state] }
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
