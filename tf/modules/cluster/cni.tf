resource "null_resource" "install_cilium" {
  depends_on = [
    null_resource.join_workers
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = local.first_cp_node.ipv4_address
  }
  provisioner "file" {
    source      = "modules/cluster/scripts/install-cilium.sh"
    destination = "/root/install-cilium.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export CILIUM_VERSION=${var.cilium_version}",
      "export CP_LB_IP=${hcloud_load_balancer.cp_lb.ipv4}",
      "chmod +x /root/install-cilium.sh",
      "/root/install-cilium.sh"
    ]
  }
}