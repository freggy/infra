module "cloud_control_plane" {
    source = "../host"
    for_each = local.cloud_cp_map

    is_hcloud_server = true
    hcloud_server_type = each.value.server_type
    hcloud_name = each.value.name
    hcloud_location = each.value.location
    hcloud_ssh_keys = each.value.initial_ssh_keys
}

module "dedi_control_plane" {
    source = "../host"
    for_each = local.dedi_cp_map

    is_dedi_server = true
    ipv4_address = each.value.ipv4_address
}

locals {
  // need to convert our nodepools into maps
  // so we can use them in for_each
  cloud_cp_map = tomap({
    for obj in var.cloud_control_plane_pools: obj.name => obj
  })
  dedi_cp_map = tomap({
    for obj in var.dedi_control_plane_pool: obj.name => obj
  })
  control_plane = merge(module.cloud_control_plane, module.dedi_control_plane)
  first_cp_node = local.control_plane[keys(local.control_plane)[0]]
}

resource "null_resource" "install_packages" {
  for_each = local.control_plane
  depends_on = [ 
    module.cloud_control_plane
  ]
  connection {
    user           = "root"
    private_key    = var.ssh_private_key
    host           = local.control_plane[each.key].ipv4_address
  }
  provisioner "file" {
    source      = "scripts/install-packages.sh"
    destination = "/root/install-packages.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "MAJOR_VERSION=${local.version_major}",
      "FULL_VERSION=${var.kubernetes_version}",
      "/root/install-packages.sh"
      ]
  }
}

/*
resource "null_resource" "first_control_plane_node" {
  depends_on = [
    // we have to wait until all cloud control planes
    // are ready. dedi control plane servers will 
    // already be ready for provisioning.
    null_resource.add_package_registries
  ]
  connection {
    user           = "root"
    private_key    = var.ssh_private_key
    host           = local.first_cp_node.ipv4_address
  }
  provisioner "local-exec" {
    command = "echo ${local.first_cp_node.ipv4_address}"
  }
}

resource "null_resource" "other_control_plane_nodes" {
  for_each = local.control_plane
  connection {
    user           = "root"
    private_key    = var.ssh_private_key
    host           = local.control_plane[each.key].ipv4_address
  }
  provisioner "local-exec" {
    command = "echo ${local.control_plane[each.key].ipv4_address}"
  }
  // TODO: provision other nodes
}*/
