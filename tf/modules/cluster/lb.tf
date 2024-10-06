resource "hcloud_server" "cp_lb" {
  name        = "${var.cluster_name}-lb"
  image       = var.load_balancer.image
  server_type = var.load_balancer.server_type
  location    = var.load_balancer.location
  ssh_keys    = var.load_balancer.initial_ssh_keys
  labels = {
    cluster = var.cluster_name
  }
}

resource "tailscale_tailnet_key" "lb_auth_key" {
  depends_on = [
    hcloud_server.cp_lb
  ]
  preauthorized = true
  expiry        = 3600
  description   = "${var.cluster_name}-lb"
}

data "tailscale_device" "lb" {
  depends_on = [
    null_resource.provision_lb
  ]
  hostname = "${var.cluster_name}-lb"
  wait_for = "60s"
}

resource "null_resource" "provision_lb" {
  depends_on = [
    hcloud_server.cp_lb
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = hcloud_server.cp_lb.ipv4_address
  }
  provisioner "file" {
    source      = "${path.module}/scripts/provision-lb.sh"
    destination = "/root/provision-lb.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export TAILSCALE_AUTH_KEY=${nonsensitive(tailscale_tailnet_key.lb_auth_key.key)}",
      "chmod +x /root/provision-lb.sh",
      "/root/provision-lb.sh",
    ]
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/haproxy.cfg.tftpl", {
      cp_nodes = local.cp
    })
    destination = "/etc/haproxy/haproxy.cfg"
  }
  provisioner "remote-exec" {
    inline = [
      "systemctl restart haproxy",
    ]
  }
}
