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
  // only enable for cloud servers, because dedicated ones have to have
  // tailscale configured beforehand. This is, so we can specify the dedicated
  // servers internal IP directly in the cluster config. Otherwise, we would
  // need to configure the public IP first and after cluster deployment change
  // it to the internal one.
  count  = var.is_hcloud_server ? 1 : 0
  source = "../tailscale_device"
  depends_on = [
    null_resource.provision
  ]
  hostname        = "${var.name}-${var.environment}"
  ssh_private_key = var.ssh_private_key
  address         = try(hcloud_server.server[0].ipv4_address, var.ipv4_address)
}

resource "cloudflare_dns_record" "a_record" {
  depends_on = [
    module.tailscale_device
  ]
  zone_id = var.cloudflare_zone_id
  name    = "${var.name}.${var.environment}"
  // in the case of a dedicated server var.ipv4_address is the internal IP
  content = try(module.tailscale_device[0].tailscale_ipv4_address, var.ipv4_address)
  type    = "A"
  ttl     = 3600
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}
