locals {
    // need to convert our nodepools into maps
    // so we can use them in for_each
    cloud_worker_servers = {
        for idx, obj in var.cloud_worker_pools :
            format("%s-%s", idx, obj.name) => {
                server_type : obj.server_type,
                name : obj.name,
                location : obj.location,
                initial_ssh_keys : obj.initial_ssh_keys,
            }
        }
    dedi_worker = {
        for idx, obj in var.dedi_worker_pool :
            format("%s-%s", idx, obj.name) => {
                ipv4_address : obj.ipv4_address,
                name : obj.name,
                labels : obj.lables,
                taints : obj.taints,
            }
        }
}