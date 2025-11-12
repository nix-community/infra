resource "github_repository" "infra" {
  name         = "infra"
  description  = "nix-community infrastructure [maintainer=@zowoq]"
  homepage_url = "https://nix-community.org"

  topics = [
    "nix-darwin",
    "nixos",
    "terraform",
  ]

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = true
  allow_squash_merge     = false
  delete_branch_on_merge = true
  has_discussions        = true
  has_issues             = true
  vulnerability_alerts   = true

  pages {
    build_type = "workflow"
    cname      = "nix-community.org"
  }
}

resource "github_repository_ruleset" "infra" {
  name        = "default branch"
  repository  = github_repository.infra.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    merge_queue {
      check_response_timeout_minutes    = 60
      grouping_strategy                 = "ALLGREEN"
      max_entries_to_build              = 1
      max_entries_to_merge              = 1
      merge_method                      = "REBASE"
      min_entries_to_merge              = 1
      min_entries_to_merge_wait_minutes = 5
    }

    pull_request {
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_approving_review_count   = 0
      required_review_thread_resolution = false
    }

    required_status_checks {
      required_check {
        context = "buildbot/nix-build"
      }
    }
  }
}
