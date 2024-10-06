variable "kubernetes_version" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cilium_version" {
  type = string
}

variable "load_balancer" {
  type = object({
    location         = string
    server_type      = string
    image            = string
    initial_ssh_keys = list(string)
  })
  default = {
    location         = "fsn1"
    server_type      = "cax11"
    image            = "ubuntu-24.04"
    initial_ssh_keys = []
  }
}

variable "cloud_cp_nodes" {
  description = "configuration of cloud control plane node pools"
  type = list(object({
    name             = string
    server_type      = string
    location         = string
    image            = string
    initial_ssh_keys = list(string)
  }))
  default = []
}

// those are to support dedicated servers, from hetzner server auction for example

variable "dedi_cp_nodes" {
  description = "list of additional control plane nodes"
  type = list(object({
    name         = string
    ipv4_address = string
    labels       = list(string)
    taints       = list(string)
  }))
  default = []
}

variable "cloud_worker_nodes" {
  description = "configuration of cloud worker node pools"
  type = list(object({
    name             = string
    server_type      = string
    location         = string
    image            = string
    initial_ssh_keys = list(string)
  }))
  default = []
}

variable "dedi_worker_nodes" {
  description = "list of additional worker nodes"
  type = list(object({
    name         = string
    ipv4_address = string
    labels       = list(string)
    taints       = list(string)
  }))
  default = []
}
