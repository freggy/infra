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
  }
}

variable "hcloud_token" {}
variable "tailscale_token" {}
variable "tailscale_tailnet" {}

provider "hcloud" {
  token = var.hcloud_token
}

provider "tailscale" {
  api_key = var.tailscale_token
  tailnet = var.tailscale_tailnet
}
