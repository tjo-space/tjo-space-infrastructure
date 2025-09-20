terraform {
  required_providers {
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.3"
    }
    desec = {
      source  = "Valodim/desec"
      version = "0.6.1"
    }
  }

  required_version = "~> 1.9.0"
}

provider "desec" {
  api_token = var.desec_token
}
