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
controlPlaneEndpoint: ${hcloud_load_balancer.load_balancer.ipv4}:6443
apiServer:
  extraArgs:
    "authorization-mode": "Node,RBAC"
    EOT
}

data "external" "join_cmd" {
  depends_on = [ 
    null_resource.first_control_plane_node
  ]
  program = ["${path.module}/scripts/join-cmd.sh"]
  query = {
    ip = local.first_cp_node.ipv4_address
  }
}

resource "random_bytes" "certkey" {
  length = 32 // 32 bits because, otherwise kubeadm complains
}