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
