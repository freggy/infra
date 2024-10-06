resource "hcloud_server" "server" {
  count       = var.is_hcloud_server ? 1 : 0
  name        = var.name
  image       = var.hcloud_image
  server_type = var.hcloud_server_type
  location    = var.hcloud_location
  ssh_keys    = var.hcloud_ssh_keys
  labels      = var.hcloud_labels
}

resource "null_resource" "provision" {
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = try(hcloud_server.server[0].ipv4_address, var.ipv4_address)
  }
  provisioner "file" {
    source      = "${path.module}/scripts/provision.sh"
    destination = "/root/provision.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export MAJOR_VERSION=${var.kubernetes_major_version}",
      "export FULL_VERSION=${var.kubernetes_version}",
      "chmod +x /root/provision.sh",
      "/root/provision.sh",
    ]
  }
}

module "tailscale_device" {
  source = "../tailscale_device"
  depends_on = [
    null_resource.provision
  ]
  hostname        = var.name
  ssh_private_key = var.ssh_private_key
  address         = try(hcloud_server.server[0].ipv4_address, var.ipv4_address)
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
  }
}
