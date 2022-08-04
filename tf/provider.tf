terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.35.1"
    }
  }

  backend "remote" {
    organization = "freggy"
    workspaces {
      name = "infra"
    }
  }
}

variable "hcloud_token" {}

provider "hcloud" {
  token = "${var.hcloud_token}"
}
