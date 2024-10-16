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

resource "hydra_project" "simple_nixos_mailserver" {
  name         = "simple-nixos-mailserver"
  display_name = "Simple NixOS MailServer"
  description  = "A complete and Simple Nixos Mailserver"
  homepage     = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver"
  owner        = "admin"
  enabled      = true
  visible      = true

  declarative {
    file  = ".hydra/spec.json"
    type  = "git"
    value = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver"
  }
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

resource "hydra_jobset" "nixpkgs_cuda" {
  project     = hydra_project.nixpkgs.name
  state       = "enabled"
  visible     = true
  name        = "cuda"
  type        = "legacy"
  description = "Testing CUDA support. Come help the CUDA team! https://nixos.org/community/teams/cuda/"

  nix_expression {
    file  = "pkgs/top-level/release-cuda.nix"
    input = "nixpkgs"
  }

  input {
    name              = "nixpkgs"
    type              = "git"
    value             = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
    notify_committers = false
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
    value             = "[ \"x86_64-linux\" ]"
    notify_committers = false
  }

  check_interval    = 1800
  scheduling_shares = 6000
  keep_evaluations  = 1

  email_notifications = false
  email_override      = ""
}

resource "hydra_jobset" "nixpkgs_rocm" {
  project     = hydra_project.nixpkgs.name
  state       = "enabled"
  visible     = true
  name        = "rocm"
  type        = "legacy"
  description = "Testing ROCm support."

  nix_expression {
    file  = "pkgs/top-level/release-cuda.nix"
    input = "nixpkgs"
  }

  input {
    name              = "variant"
    type              = "string"
    value             = "rocm"
    notify_committers = false
  }

  input {
    name              = "nixpkgs"
    type              = "git"
    value             = "https://github.com/NixOS/nixpkgs.git nixos-unstable-small"
    notify_committers = false
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
    value             = "[ \"x86_64-linux\" ]"
    notify_committers = false
  }

  check_interval    = 1800
  scheduling_shares = 6000
  keep_evaluations  = 1

  email_notifications = false
  email_override      = ""
}
