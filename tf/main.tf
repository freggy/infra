data "cloudflare_zone" "main" {
  filter = {
    name = "76k.io"
  }
}

module "app1_euc" {
  source = "./modules/cluster"
  providers = {
    hcloud = hcloud
  }
  cluster_name       = "app1-euc"
  environment        = "prod"
  cloudflare_zone_id = data.cloudflare_zone.main.id
  cilium_version     = "1.16.2"
  kubernetes_version = "1.30.0-1.1"
  ssh_private_key    = file("~/.ssh/id_ed25519")
  load_balancer = {
    name             = "cp1"
    server_type      = "cax11"
    image            = "ubuntu-24.04"
    location         = "hel1"
    initial_ssh_keys = ["yannic-mac-work"]
  }
  cloud_cp_nodes = [
    {
      name             = "cp1"
      server_type      = "cax11"
      image            = "ubuntu-24.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic-mac-work"]
    },
    {
      name             = "cp2"
      server_type      = "cax11"
      image            = "ubuntu-24.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic-mac-work"]
    },
  ]
  cloud_worker_nodes = [
    {
      name             = "w1"
      server_type      = "cax21"
      image            = "ubuntu-24.04"
      location         = "hel1"
      initial_ssh_keys = ["yannic-mac-work"]
    },
  ]
}
