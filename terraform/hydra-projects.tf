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

  declarative {
    file = "hydra/spec.json"
    type = "git"
    value = "https://github.com/nix-community/emacs-overlay"
  }
}

# Currently unmaintained:
#resource "hydra_project" "nix_data" {
#  name         = "nix-data"
#  display_name = "nix-data"
#  description  = "Standard set of packages and overlays for data-scientists"
#  homepage     = "https://github.com/nix-community/nix-data"
#  owner        = "admin"
#  enabled      = true
#  visible      = true
#
#  declarative {
#    file = "spec.json"
#    type = "git"
#    value = "https://github.com/nix-community/nix-data"
#  }
#}

resource "hydra_project" "simple_nixos_mailserver" {
  name         = "simple-nixos-mailserver"
  display_name = "Simple NixOS MailServer"
  description  = "A complete and Simple Nixos Mailserver"
  homepage     = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver"
  owner        = "admin"
  enabled      = true
  visible      = true

  declarative {
    file = ".hydra/spec.json"
    type = "git"
    value = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver"
  }
}

# Currently unmaintained:
#resource "hydra_project" "redoxpkgs" {
#  name         = "redoxpkgs"
#  display_name = "Redoxpkgs"
#  description  = "Packages for Redox"
#  homepage     = "https://github.com/nix-community/redoxpkgs"
#  owner        = "admin"
#  enabled      = true
#  visible      = true
#
#  declarative {
#    file = ".hydra/spec.json"
#    type = "git"
#    value = "https://github.com/nix-community/redoxpkgs"
#  }
#}

# Currently unmaintained:
#resource "hydra_project" "rust_for_linux" {
#  name         = "rust-for-linux"
#  display_name = "Rust For Linux"
#  description  = "Linux Kernel with Rust support"
#  homepage     = "https://github.com/Rust-for-Linux/linux"
#  owner        = "admin"
#  enabled      = true
#  visible      = true
#
#  declarative {
#    file = ".hydra/spec.json"
#    type = "git"
#    value = "https://github.com/rust-for-linux/nix"
#  }
#}
