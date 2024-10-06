resource "tailscale_tailnet_key" "auth_key" {
  preauthorized = true
  expiry        = 3600
  description   = var.hostname
}

data "tailscale_device" "device" {
  depends_on = [
    null_resource.install
  ]
  hostname = var.hostname
  wait_for = "60s"
}

resource "null_resource" "install" {
  depends_on = [
    tailscale_tailnet_key.auth_key
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = var.address
  }
  provisioner "file" {
    source      = "${path.module}/scripts/install-tailscale.sh"
    destination = "/root/install-tailscale.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export TAILSCALE_AUTH_KEY=${nonsensitive(tailscale_tailnet_key.auth_key.key)}",
      "chmod +x /root/install-tailscale.sh",
      "/root/install-tailscale.sh",
    ]
  }
}

resource "null_resource" "configure_sshd" {
  depends_on = [
    data.tailscale_device.device
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = var.address
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/tailscale_sshd.conf", {
      ip = sort(data.tailscale_device.device.addresses)[0]
    })
    destination = "/etc/ssh/sshd_config.d/tailscale_sshd.conf"
  }
  provisioner "remote-exec" {
    inline = [
      // somehow we need to wait a bit before
      // restarting sshd, otherwise our changes
      // are not getting picked up.
      "sleep 1",
      "systemctl restart ssh"
    ]
  }
}

terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.17.1"
    }
  }
}
