terraform {
  backend "oras" {
    repository = "ghcr.io/nix-community/infra/terraform-state"
  }

  encryption {
    key_provider "pbkdf2" "encryption_key_provider" {
      passphrase = var.passphrase
    }

    method "aes_gcm" "encryption_method" {
      keys = key_provider.pbkdf2.encryption_key_provider
    }

    plan {
      method   = method.aes_gcm.encryption_method
      enforced = true
    }

    state {
      method   = method.aes_gcm.encryption_method
      enforced = true
    }
  }
}

variable "passphrase" {
  sensitive = true
}
