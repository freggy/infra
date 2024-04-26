locals {
    cloud_cp_servers = {
        for idx, obj in var.cloud_control_plane_nodepools :
            format("%s", idx) => {
                server_type : obj.server_type,
                name : obj.name,
                location : obj.location,
                ssh_keys : obj.ssh_keys,
            }
        }
    cloud_worker_servers = {
        for idx, obj in var.cloud_worker_nodepools :
            format("%s", idx) => {
                server_type : obj.server_type,
                name : obj.name,
                location : obj.location,
                ssh_keys : obj.ssh_keys,
            }
        }
    dedi_cp = {
        for idx, obj in var.additional_control_plane_addrs :
            format("%s", idx) => {
                addr : obj.addr,
                name : obj.name,
                labels : obj.lables,
                taints : obj.taints,
            }
        }
    dedi_worker = {
        for idx, obj in var.additional_worker_addrs :
            format("%s", idx) => {
                addr : obj.addr,
                name : obj.name,
                labels : obj.lables,
                taints : obj.taints,
            }
        }
}