resource "hcloud_load_balancer" "saturn-control-plane-lb" {
  name = "saturn-api-servers"
  load_balancer_type = "lb11"
  location = "fsn1"
  labels = {
    cluster = "saturn"
  }
}

resource "hcloud_load_balancer_target" "saturn-control-plane-lb-target" {
  type = "label_selector"
  load_balancer_id = hcloud_load_balancer.saturn-control-plane-lb.id
  label_selector = "saturn-master"
}

resource "hcloud_load_balancer_service" "saturn-control-plane-lb-service" {
  load_balancer_id = hcloud_load_balancer.saturn-control-plane-lb.id
  protocol = "http"
  listen_port = 80
  destination_port = 443
  health_check {
    protocol = "tcp"
    port = 443
    interval = 30
    timeout = 10
    retries = 3
  }
}

resource "hcloud_server" "saturn-masters" {
  count = 2
  name = "master${count.index + 1}-saturn-k8s-freggy-dev"
  image = "debian-11"
  server_type = "cpx11"
  location = "fsn1"
  ssh_keys = ["saturn-mgmt"]
  labels = {
    roles = "saturn.kube_master"
    cluster = "saturn"
    saturn-master = "true"
  }
}

resource "hcloud_server" "saturn-workers" {
  count = 5
  name = "worker${count.index + 1}-saturn-k8s-freggy-dev"
  image = "debian-11"
  server_type = "cx21"
  ssh_keys = ["saturn-mgmt"]
  location = "fsn1"
  labels = {
    roles = "saturn.kube_worker"
    cluster = "saturn"
  }
}
