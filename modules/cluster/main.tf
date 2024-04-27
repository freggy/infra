module "cloud_worker" {
    source = "../host"
    for_each = local.cloud_worker_servers

    is_hcloud_server = true
    hcloud_server_type = each.value.server_type
    hcloud_name = each.value.name
    hcloud_location = each.value.location
    hcloud_ssh_keys = each.value.initial_ssh_keys
}

locals {
  // example version string: 1.29.4-150500.2.1
  // [0] [1]    [2]   [3] [4]
  //  1  29  4-150500  2   1 
  version_array = split(".", var.kubernetes_version)
  
  // 1.29
  version_major = join(".", slice(local.version_array, 0, 1))

  // first we do:
  //    join(".", slice(local.version_array, 0, 2))
  // this will give us 
  //    1.29.4-150500
  // then split this by `-` and get the first entry:
  //    1.29.4
  version_minor = split("-", join(".", slice(local.version_array, 0, 2)))[0]
}

module "dedi_worker" {
    source = "../host"
    for_each = local.dedi_worker

    is_dedi_server = true
    ipv4_address = each.value.ipv4_address
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
  }
}
