module "cluster01" {
    source = "./modules/cluster"

    kubernetes_version = "v1.30"
    cloud_control_plane_nodepools = [ 
        {
            name                       = "string"
            server_type                = "string"
            location                   = "string"
            labels                     = []
            taints                     = []
            ssh_keys = []
            count                      = 1
        }
     ]
}