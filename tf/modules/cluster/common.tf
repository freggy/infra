locals {
  cluster_config = <<EOT
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///var/run/crio/crio.sock
certificateKey: ${random_bytes.certkey.hex}
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: ${var.cluster_name}
kubernetesVersion: '${local.version_minor}'
controlPlaneEndpoint: ${hcloud_load_balancer.cp_lb.ipv4}:6443
apiServer:
  extraArgs:
    "authorization-mode": "Node,RBAC"
    EOT

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

data "external" "join_cmd" {
  depends_on = [
    null_resource.first_cp_node
  ]
  program = ["${path.module}/scripts/join-cmd.sh"]
  query = {
    ip = local.first_cp_node.ipv4_address
  }
}

resource "random_bytes" "certkey" {
  length = 32 // 32 bits because, otherwise kubeadm complains
}

resource "null_resource" "install_packages" {
  for_each = merge(local.cp, local.workers)
  depends_on = [
    module.cloud_worker,
    module.cloud_cp
  ]
  connection {
    user        = "root"
    private_key = var.ssh_private_key
    host        = each.value.ipv4_address
  }
  provisioner "file" {
    source      = "modules/cluster/scripts/prepare-node.sh"
    destination = "/root/install-packages.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "export MAJOR_VERSION=${local.version_major}",
      "export FULL_VERSION=${var.kubernetes_version}",
      "chmod +x /root/install-packages.sh",
      "/root/install-packages.sh"
    ]
  }
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
  }
}