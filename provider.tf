terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.35.1"
    }
  }
}

variable "hcloud_token" {}

provider "hcloud" {
  token = "${var.hcloud_token}"
}
