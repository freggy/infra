resource "hloud_server" "saturn-masters" {
  count = 2
  name = "master${count.index + 1}-saturn-k8s-freggy-dev"
  image = "debian-11"
  server_type = "cpx11"
  location = "fsn1"
  ssh_keys = ["management-key"]
  labels = {
    roles = "saturn.kube_master"
    cluster = "saturn"
  }
}

resource "hcloud_server" "saturn-workers" {
  count = 5
  name = "worker${count.index + 1}-saturn-k8s-freggy-dev"
  image = "debian-11"
  server_type = "cx21"
  ssh_keys = ["management-key"]
  location = "fsn1"
  labels = {
    roles = "saturn.kube_worker"
    cluster = "saturn"
  }
}
