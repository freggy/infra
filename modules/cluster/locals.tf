locals {
    // need to convert our nodepools into maps
    // so we can use them in for_each
    cloud_cp_servers = {
        for idx, obj in var.cloud_control_plane_pools :
            format("%s", idx) => {
                server_type : obj.server_type,
                name : obj.name,
                location : obj.location,
                initial_ssh_keys : obj.initial_ssh_keys,
            }
        }
    cloud_worker_servers = {
        for idx, obj in var.cloud_worker_pools :
            format("%s", idx) => {
                server_type : obj.server_type,
                name : obj.name,
                location : obj.location,
                initial_ssh_keys : obj.initial_ssh_keys,
            }
        }
    dedi_cp = {
        for idx, obj in var.var.dedi_control_plane_pool :
            format("%s", idx) => {
                addr : obj.addr,
                name : obj.name,
                labels : obj.lables,
                taints : obj.taints,
            }
        }
    dedi_worker = {
        for idx, obj in var.var.dedi_worker_pool :
            format("%s", idx) => {
                addr : obj.addr,
                name : obj.name,
                labels : obj.lables,
                taints : obj.taints,
            }
        }
}