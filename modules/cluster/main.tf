module "cloud_control_plane" {
    source = "../host"
    for_each = local.cloud_cp_servers
    
    is_hcloud_server = true
    hcloud_server_type = each.value.server_type
    hcloud_name = each.value.name
    hcloud_location = each.value.location
    hcloud_ssh_keys = each.value.initial_ssh_keys
}

module "cloud_worker" {
    source = "../host"
    for_each = local.cloud_worker_servers

    is_hcloud_server = true
    hcloud_server_type = each.value.server_type
    hcloud_name = each.value.name
    hcloud_location = each.value.location
    hcloud_ssh_keys = each.value.initial_ssh_keys
}

module "dedi_worker" {
    source = "../host"
    for_each = local.dedi_worker

    is_dedi_server = true
    addr = each.value.addr
}
