terraform {
  required_proiders {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.25.2"
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
