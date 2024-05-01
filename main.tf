module "cluster01" {
  source = "./modules/cluster"
  providers = {
    hcloud = hcloud
  }
  kubernetes_version = "v1.30"
  ssh_private_key    = ""
  cloud_control_plane_pools = [ 
    {
      name             = "cloud-cp-0"
      server_type      = "cx11"
      location         = "hel1"
      labels           = []
      taints           = []
      initial_ssh_keys = []
      count            = 1
    }
  ]
  dedi_control_plane_pool = [
    {
      name = "dedi-cp-0"
      ipv4_address = "1.1.1.1"
      labels       = []
      taints       = []
    } 
  ]
}