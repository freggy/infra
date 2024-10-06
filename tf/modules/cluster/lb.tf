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

module "lb_tailscale_device" {
  source = "../tailscale_device"
  depends_on = [
    hcloud_server.cp_lb
  ]
  hostname        = "${var.cluster_name}-lb"
  ssh_private_key = var.ssh_private_key
  address         = hcloud_server.cp_lb.ipv4_address
}
