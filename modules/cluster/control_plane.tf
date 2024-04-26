module "cloud_control_plane" {
    source = "../host"
    for_each = local.cloud_cp_servers
    
    is_hcloud_server = true
    hcloud_server_type = each.value.server_type
    hcloud_name = each.value.name
    hcloud_location = each.value.location
    hcloud_ssh_keys = each.value.ssh_keys
}

module "dedi_control_plane" {
    source = "../host"
    for_each = local.dedi_cp

    is_dedi_server = true
    addr = each.value.addr
}

resource "null_resource" "first_control_plane_node" {
  connection {
    user           = "root"
    private_key    = var.ssh_private_key
    host           = module.control_planes[keys(module.control_planes)[0]].ipv4_address
  }
  // TODO: provision first control-plane
}

resource "null_resource" "other_control_plane_nodes" {
  connection {
    user           = "root"
    private_key    = var.ssh_private_key
    host           = module.control_planes[each.key].ipv4_address
  }
  // TODO: provision other nodes
}