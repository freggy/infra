module "cluster01" {
  source = "./modules/cluster"
  providers = {
    hcloud = hcloud
  }
  kubernetes_version = "1.30.0-1.1"
  cluster_name       = "dev1-euc"
  ssh_private_key    = file("~/.ssh/id_ed25519")
  cilium_version     = "1.15.4"
  cloud_cp_nodes     = [
    {
      name             = "dev1-euc-cp1"
      server_type      = "cax11"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
    {
      name             = "dev1-euc-cp2"
      server_type      = "cax11"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
  ]
  cloud_worker_nodes = [
    {
      name             = "dev1-euc-w1"
      server_type      = "cax21"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
    {
      name             = "dev1-euc-w2"
      server_type      = "cax21"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
  ]
}