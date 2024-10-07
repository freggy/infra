locals {
  lb_hostname = "lb-${var.cluster_name}"
}

resource "hcloud_server" "cp_lb" {
  name        = local.lb_hostname
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
  hostname        = "${local.lb_hostname}-${var.environment}"
  ssh_private_key = var.ssh_private_key
  address         = hcloud_server.cp_lb.ipv4_address
}

resource "cloudflare_dns_record" "lb_a_record" {
  depends_on = [
    module.lb_tailscale_device
  ]
  zone_id = var.cloudflare_zone_id
  name    = "${local.lb_hostname}.${var.environment}"
  content = module.lb_tailscale_device.tailscale_ipv4_address
  type    = "A"
  ttl     = 3600
}

resource "null_resource" "update_lb_config" {
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = module.lb_tailscale_device.tailscale_ipv4_address
  }
  triggers = {
    sha1 = "${sha1(file("${path.module}/templates/haproxy.cfg.tftpl"))}"
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/haproxy.cfg.tftpl", {
      cp_nodes = local.cp
    })
    destination = "/etc/haproxy/haproxy.cfg.new"
  }
  provisioner "remote-exec" {
    inline = [
      "haproxy -f /etc/haproxy/haproxy.cfg.new -c" // check if config is valid
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "mv /etc/haproxy/haproxy.cfg.new /etc/haproxy/haproxy.cfg",
      "systemctl restart haproxy",
    ]
  }
}
