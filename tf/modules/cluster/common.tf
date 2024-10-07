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

  cert_key = nonsensitive(random_bytes.certkey.hex)

  lb_tailscale_ipv4_address = module.lb_tailscale_device.tailscale_ipv4_address
}

data "external" "bootstrap_token" {
  depends_on = [
    null_resource.first_cp_node
  ]
  program = ["${path.module}/scripts/create-bootstrap-token.sh"]
  query = {
    ip = local.first_cp_node.tailscale_ipv4_address
  }
}

resource "random_bytes" "certkey" {
  length = 32 // 32 bits because, otherwise kubeadm complains
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
  }
}
