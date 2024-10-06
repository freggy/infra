module "app1_euc" {
  source = "./modules/cluster"
  providers = {
    hcloud = hcloud
  }
  kubernetes_version = "1.30.0-1.1"
  cluster_name       = "app1-euc"
  ssh_private_key    = file("~/.ssh/id_ed25519")
  cilium_version     = "1.16.2"
  load_balancer = {
    name             = "app1-euc-cp1"
    server_type      = "cax11"
    image            = "ubuntu-24.04"
    location         = "hel1"
    initial_ssh_keys = ["yannic-mac-work"]
  }
  cloud_cp_nodes = [
    {
      name             = "app1-euc-cp1"
      server_type      = "cax11"
      image            = "ubuntu-24.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic-mac-work"]
    },
    {
      name             = "app1-euc-cp2"
      server_type      = "cax11"
      image            = "ubuntu-24.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic-mac-work"]
    },
  ]
  cloud_worker_nodes = [
    {
      name             = "app1-euc-w1"
      server_type      = "cax21"
      image            = "ubuntu-24.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic-mac-work"]
    },
  ]
}
