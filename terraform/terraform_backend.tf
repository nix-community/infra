terraform {
  backend "pg" {
    conn_str = "postgres://terraform@localhost/terraform?sslmode=disable"
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
