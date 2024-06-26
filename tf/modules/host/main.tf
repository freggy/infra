resource "hcloud_server" "server" {
  count       = var.is_hcloud_server ? 1 : 0
  name        = var.name
  image       = var.hcloud_image
  server_type = var.hcloud_server_type
  location    = var.hcloud_location
  ssh_keys    = var.hcloud_ssh_keys
  labels      = var.hcloud_labels
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
  }
}
