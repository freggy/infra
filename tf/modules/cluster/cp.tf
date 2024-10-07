locals {
  // need to convert our node templates into maps
  // so we can use them in for_each
  cloud_cp_map = tomap({
    for obj in var.cloud_cp_nodes : obj.name => obj
  })
  dedi_cp_map = tomap({
    for obj in var.dedi_cp_nodes : obj.name => obj
  })
  cp            = merge(module.cloud_cp, module.dedi_cp)
  first_cp_node = local.cp[keys(local.cp)[0]]
}

/*
 * actual resources
 */

module "cloud_cp" {
  source   = "../host"
  for_each = local.cloud_cp_map

  is_hcloud_server         = true
  name                     = "${each.value.name}-${var.cluster_name}"
  hcloud_server_type       = each.value.server_type
  hcloud_location          = each.value.location
  hcloud_image             = each.value.image
  hcloud_ssh_keys          = each.value.initial_ssh_keys
  kubernetes_version       = var.kubernetes_version
  kubernetes_major_version = local.version_major
  ssh_private_key          = var.ssh_private_key
  hcloud_labels = {
    cluster   = var.cluster_name
    node-type = "control-plane"
  }
  cloudflare_zone_id = var.cloudflare_zone_id
  environment        = var.environment
}

module "dedi_cp" {
  source   = "../host"
  for_each = local.dedi_cp_map

  is_dedi_server           = true
  name                     = "${each.value.name}-${var.cluster_name}"
  ipv4_address             = each.value.ipv4_address
  kubernetes_version       = var.kubernetes_version
  kubernetes_major_version = local.version_major
  ssh_private_key          = var.ssh_private_key
  cloudflare_zone_id       = var.cloudflare_zone_id
  environment              = var.environment
}

/*
 * provisioning logic
 */

resource "null_resource" "first_cp_node" {
  depends_on = [
    null_resource.provision_lb
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = local.first_cp_node.tailscale_ipv4_address
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/kubeadm_init_config.tftpl", {
      node_ip                  = local.first_cp_node.tailscale_ipv4_address,
      cert_key                 = local.cert_key,
      cluster_name             = var.cluster_name,
      kubernetes_minor_version = local.version_minor,
      cp_endpoint              = "${module.lb_tailscale_device.tailscale_ipv4_address}:6443",
    })
    destination = "/root/kubeadm_config.yaml"
  }
  provisioner "file" {
    source      = "modules/cluster/scripts/init-cp-node.sh"
    destination = "/root/init-cp-node.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/init-cp-node.sh",
      "/root/init-cp-node.sh"
    ]
  }
}

resource "null_resource" "other_cp_nodes" {
  for_each = local.cp
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = each.value.tailscale_ipv4_address
  }
  provisioner "file" {
    source      = "${path.module}/scripts/join-node.sh"
    destination = "/root/join-node.sh"
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/kubeadm_cp_config.tftpl", {
      node_ip         = each.value.tailscale_ipv4_address,
      cert_key        = local.cert_key,
      cp_endpoint     = "${module.lb_tailscale_device.tailscale_ipv4_address}:6443",
      bootstrap_token = data.external.bootstrap_token.result.cmd
    })
    destination = "/root/kubeadm_config.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      "export CERT_KEY=${local.cert_key}",
      "chmod +x /root/join-node.sh",
      "/root/join-node.sh"
    ]
  }
}
