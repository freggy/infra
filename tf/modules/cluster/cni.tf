resource "null_resource" "install_cilium" {
  depends_on = [
    null_resource.join_workers
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = local.first_cp_node.tailscale_ipv4_address
  }
  provisioner "file" {
    source      = "${path.module}/scripts/install-cilium.sh"
    destination = "/root/install-cilium.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export CILIUM_VERSION=${var.cilium_version}",
      "export CP_LB_IP=${local.lb_tailscale_ipv4_address}",
      "chmod +x /root/install-cilium.sh",
      "/root/install-cilium.sh"
    ]
  }
}
