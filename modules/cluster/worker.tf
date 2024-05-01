locals {
  // need to convert our nodepools into maps
  // so we can use them in for_each
  cloud_worker_map = tomap({
    for obj in var.cloud_workers: obj.name => obj
  })
  dedi_worker_map = tomap({
    for obj in var.dedi_workers: obj.name => obj
  })
  workers = merge(module.cloud_worker, module.dedi_worker)
}

/*
 * actual resources
 */ 

module "cloud_worker" {
    source   = "../host"
    for_each = local.cloud_worker_map

    is_hcloud_server   = true
    name               = each.value.name
    hcloud_server_type = each.value.server_type
    hcloud_location    = each.value.location
    hcloud_ssh_keys    = each.value.initial_ssh_keys
}

module "dedi_worker" {
    source   = "../host"
    for_each = local.dedi_worker_map

    is_dedi_server = true
    name           = each.value.name
    ipv4_address   = each.value.ipv4_address
}

/*
 * provisioning
 */

resource "null_resource" "join_workers" {
  for_each = local.workers
  depends_on = [ 
    null_resource.other_control_plane_nodes
  ]
  connection {
    user           = "root"
    private_key    = var.ssh_private_key
    host           = each.value.ipv4_address
  }
  provisioner "file" {
    source      = "modules/cluster/scripts/join-node.sh"
    destination = "/root/join-node.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export JOIN_CMD='${data.external.join_cmd.result.cmd}'",
      "export CERT_KEY=${random_bytes.certkey.hex}",
      "chmod +x /root/join-node.sh",
      "/root/join-node.sh"
    ]
  }
}