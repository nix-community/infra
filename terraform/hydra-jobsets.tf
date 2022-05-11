resource "hydra_project" "kittybox" {
  name         = "kittybox"
  display_name = "Kittybox"
  description  = "The IndieWeb blogging solution"
  homepage     = "https://gitlab.com/kittybox/kittybox"
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

  flake_uri = "gitlab:kittybox/kittybox"

  check_interval    = 300
  scheduling_shares = 3000
  keep_evaluations  = 3

  email_notifications = false
  #email_override      = ""
}
