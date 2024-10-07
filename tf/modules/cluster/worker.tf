locals {
  // need to convert our node templates into maps
  // so we can use them in for_each
  cloud_worker_map = tomap({
    for obj in var.cloud_worker_nodes : obj.name => obj
  })
  dedi_worker_map = tomap({
    for obj in var.dedi_worker_nodes : obj.name => obj
  })
  workers = merge(module.cloud_worker, module.dedi_worker)
}

/*
 * actual resources
 */

module "cloud_worker" {
  source   = "../host"
  for_each = local.cloud_worker_map

  is_hcloud_server         = true
  name                     = "${each.value.name}-${var.cluster_name}"
  hcloud_server_type       = each.value.server_type
  hcloud_location          = each.value.location
  hcloud_ssh_keys          = each.value.initial_ssh_keys
  kubernetes_version       = var.kubernetes_version
  kubernetes_major_version = local.version_major
  ssh_private_key          = var.ssh_private_key
  cloudflare_zone_id       = var.cloudflare_zone_id
  environment              = var.environment
}

module "dedi_worker" {
  source   = "../host"
  for_each = local.dedi_worker_map

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
 * provisioning
 */

resource "null_resource" "join_workers" {
  for_each = local.workers
  depends_on = [
    null_resource.other_cp_nodes
  ]
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
    content = templatefile("${path.module}/templates/kubeadm_worker_config.tftpl", {
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
