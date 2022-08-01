resource "hloud_server" "mars-masters" {
  count = 2
  name = "master${count.index + 1}-mars-k8s-freggy-dev"
  image = "debian-11"
  server_type = "cpx11"
  location = "fsn1"
  ssh_keys = ["management-key"]
  labels = {
    roles = "mars.kube_master"
    cluster = "mars"
  }
}

resource "hcloud_server" "mars-workers" {
  count = 5
  name = "worker${count.index + 1}-mars-k8s-freggy-dev"
  image = "debian-11"
  server_type = "cx21"
  ssh_keys = ["management-key"]
  location = "fsn1"
  labels = {
    roles = "mars.kube_worker"
    cluster = "mars"
  }
}
