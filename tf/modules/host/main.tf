resource "hcloud_server" "server" {
  count       = var.is_hcloud_server ? 1 : 0
  name        = var.name
  image       = var.hcloud_image
  server_type = var.hcloud_server_type
  location    = var.hcloud_location
  ssh_keys    = var.hcloud_ssh_keys
  labels      = var.hcloud_labels
}

resource "tailscale_tailnet_key" "auth_key" {
  depends_on = [
    hcloud_server.server
  ]
  preauthorized = true
  expiry        = 3600
  description   = var.name
}

data "tailscale_device" "device" {
  depends_on = [
    null_resource.provision
  ]
  hostname = var.name
  wait_for = "60s"
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
      "export TAILSCALE_AUTH_KEY=${nonsensitive(tailscale_tailnet_key.auth_key.key)}",
      "chmod +x /root/provision.sh",
      "/root/provision.sh",
    ]
  }
}

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
