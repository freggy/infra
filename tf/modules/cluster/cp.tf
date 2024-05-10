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

  is_hcloud_server   = true
  name               = each.value.name
  hcloud_server_type = each.value.server_type
  hcloud_location    = each.value.location
  hcloud_image       = each.value.image
  hcloud_ssh_keys    = each.value.initial_ssh_keys
  hcloud_labels = {
    cluster   = var.cluster_name
    node-type = "control-plane"
  }
}

module "dedi_cp" {
  source   = "../host"
  for_each = local.dedi_cp_map

  is_dedi_server = true
  name           = each.value.name
  ipv4_address   = each.value.ipv4_address
}

resource "hcloud_load_balancer" "cp_lb" {
  name               = "${var.cluster_name}-lb"
  load_balancer_type = var.load_balancer.type
  location           = var.load_balancer.location
}

resource "hcloud_load_balancer_service" "cp" {
  load_balancer_id = hcloud_load_balancer.cp_lb.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}

resource "hcloud_load_balancer_target" "cloud_cp" {
  load_balancer_id = hcloud_load_balancer.cp_lb.id
  type             = "label_selector"
  label_selector   = "cluster=${var.cluster_name},node-type=control-plane"
}

/*
 * provisioning logic
 */

resource "null_resource" "first_cp_node" {
  depends_on = [
    // we have to wait until all cloud control planes
    // are ready. dedi control plane servers will 
    // already be ready for provisioning.
    null_resource.install_packages,
    hcloud_load_balancer.cp_lb
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = local.first_cp_node.ipv4_address
  }
  provisioner "file" {
    content     = local.cluster_config
    destination = "/root/cluster_config.yaml"
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
    host        = each.value.ipv4_address
  }
  provisioner "file" {
    source      = "modules/cluster/scripts/join-node.sh"
    destination = "/root/join-node.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export JOIN_CMD='${data.external.join_cmd.result.cmd}'",
      "export CERT_KEY=${random_bytes.certkey.hex}",
      "export IS_CP=true",
      "chmod +x /root/join-node.sh",
      "/root/join-node.sh"
    ]
  }
}
