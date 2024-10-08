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
      "export HOSTNAME=${var.hostname}",
      "chmod +x /root/install-tailscale.sh",
      "/root/install-tailscale.sh",
    ]
  }
}

// there is a known bug that tailscaled tells services is ready
// even though the IP has not been bound to the interface yet,
// so wait unitl its ready.
// see https://github.com/tailscale/tailscale/issues/11504#issuecomment-2113331262
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
    content = templatefile("${path.module}/files/tailscale_sshd.conf.tftpl", {
      ip = sort(data.tailscale_device.device.addresses)[0]
    })
    destination = "/etc/ssh/sshd_config.d/tailscale_sshd.conf"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/wait-for-ip.sh"
    destination = "/root/wait-for-ip.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/systemd/system/tailscaled.service.d"
    ]
  }
  provisioner "file" {
    source      = "${path.module}/files/override.conf"
    destination = "/etc/systemd/system/tailscaled.service.d/override.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/wait-for-ip.sh",
      "systemctl daemon-reload",
      "reboot",
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
