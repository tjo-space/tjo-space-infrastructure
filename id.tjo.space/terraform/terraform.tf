terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.50.0"
    }
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "1.8.0"
    }
  }

  required_version = "~> 1.7.3"
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "dnsimple" {
  token   = var.dnsimple_token
  account = var.dnsimple_account_id
}
