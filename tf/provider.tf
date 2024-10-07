terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.17.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}

variable "hcloud_token" {}
variable "tailscale_token" {}
variable "tailscale_tailnet" {}
variable "cloudflare_token" {}
variable "cloudflare_account_id" {}

provider "hcloud" {
  token = var.hcloud_token
}

provider "tailscale" {
  api_key = var.tailscale_token
  tailnet = var.tailscale_tailnet
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}
