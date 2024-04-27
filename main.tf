module "cluster01" {
    source = "./modules/cluster"

    kubernetes_version = "v1.30"
    ssh_private_key = ""
    cloud_control_plane_pools = [ 
        {
            name                       = "string"
            server_type                = "string"
            location                   = "string"
            labels                     = []
            taints                     = []
            initial_ssh_keys = []
            count                      = 1
        }
     ]
}