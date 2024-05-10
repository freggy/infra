module "app1_euc" {
  source = "./modules/cluster"
  providers = {
    hcloud = hcloud
  }
  kubernetes_version = "1.30.0-1.1"
  cluster_name       = "app1-euc"
  ssh_private_key    = file("~/.ssh/id_ed25519")
  cilium_version     = "1.15.4"
  load_balancer = {
    type     = "lb11"
    location = "hel1"
  }
  cloud_cp_nodes     = [
    {
      name             = "app1-euc-cp1"
      server_type      = "cax11"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
    {
      name             = "app1-euc-cp2"
      server_type      = "cax11"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
  ]
  cloud_worker_nodes = [
    {
      name             = "app1-euc-w1"
      server_type      = "cax21"
      image            = "ubuntu-22.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
    {
      name             = "app1-euc-w2"
      server_type      = "cax21"
      image            = "debian-12"
      location         = "hel1"
      initial_ssh_keys = ["yannic"]
    },
  ]
}