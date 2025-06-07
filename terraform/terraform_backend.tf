terraform {
  # will import resources into new project, won't transfer existing state
  backend "s3" {
    endpoint = "s3.nix-community.org"
    # opentofu 1.10
    use_lockfile = true
  }

  encryption {
    plan {
      enforced = true
    }

    state {
      enforced = true
    }
  }
}
