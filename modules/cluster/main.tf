locals {
  // example version string: 1.29.4-150500.2.1
  // [0] [1]    [2]   [3] [4]
  //  1  29  4-150500  2   1 
  version_array = split(".", var.kubernetes_version)
  
  // 1.29
  version_major = join(".", slice(local.version_array, 0, 2))

  // first we do:
  //    join(".", slice(local.version_array, 0, 2))
  // this will give us 
  //    1.29.4-150500
  // then split this by `-` and get the first entry:
  //    1.29.4
  version_minor = split("-", join(".", slice(local.version_array, 0, 3)))[0]
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
  }
}
