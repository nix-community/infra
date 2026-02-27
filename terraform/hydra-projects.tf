# See https://github.com/DeterminateSystems/terraform-provider-hydra for explanation

resource "hydra_project" "kittybox" {
  name         = "kittybox"
  display_name = "Kittybox"
  description  = "The IndieWeb blogging solution"
  homepage     = "https://sr.ht/~vikanezrimaya/kittybox"
  owner        = "admin"
  enabled      = true
  visible      = true
}

resource "hydra_jobset" "kittybox" {
  project     = hydra_project.kittybox.name
  state       = "enabled"
  visible     = true
  name        = "main"
  type        = "flake"
  description = "main branch"

  flake_uri = "git+https://git.sr.ht/~vikanezrimaya/kittybox?ref=main"

  check_interval    = 1800
  scheduling_shares = 3000
  keep_evaluations  = 3

  email_notifications = false
}

resource "hydra_project" "emacs_overlay" {
  name         = "emacs-overlay"
  display_name = "Emacs Overlay"
  description  = "Bleeding edge emacs overlay"
  homepage     = "https://github.com/nix-community/emacs-overlay"
  owner        = "admin"
  enabled      = true
  visible      = true
}

resource "hydra_jobset" "emacs_overlay" {
  project     = hydra_project.emacs_overlay.name
  state       = "enabled"
  visible     = true
  name        = "master"
  type        = "flake"
  description = "master branch"

  flake_uri = "github:nix-community/emacs-overlay"

  check_interval    = 1800
  scheduling_shares = 3000
  keep_evaluations  = 1

  email_notifications = false
}

resource "hydra_project" "microvm_nix" {
  name         = "microvm-nix"
  display_name = "MicroVM.nix"
  description  = "NixOS MicroVMs"
  homepage     = "https://github.com/astro/microvm.nix"
  owner        = "admin"
  enabled      = true
  visible      = true
}

resource "hydra_jobset" "microvm_nix" {
  project     = hydra_project.microvm_nix.name
  state       = "disabled"
  visible     = true
  name        = "main"
  type        = "flake"
  description = "main branch"

  flake_uri = "github:astro/microvm.nix"

  check_interval    = 1800
  scheduling_shares = 3000
  keep_evaluations  = 1

  email_notifications = false
}

resource "hydra_project" "nixbsd" {
  name         = "nixbsd"
  display_name = "NixBSD"
  description  = "NixBSD"
  homepage     = "https://github.com/nixos-bsd/nixbsd"
  owner        = "admin"
  enabled      = true
  visible      = true
}

resource "hydra_jobset" "nixbsd" {
  project     = hydra_project.nixbsd.name
  state       = "enabled"
  visible     = true
  name        = "main"
  type        = "flake"
  description = "main branch"

  flake_uri = "github:nixos-bsd/nixbsd"

  check_interval    = 1800
  scheduling_shares = 1000
  keep_evaluations  = 1

  email_notifications = false
}
