variable "kubernetes_version" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "load_balancer" {
  type = object({
    location = string
    type = string
  })
  default = {
    location = "fsn1"
    type = "lb11"
  }
}

variable "cloud_control_plane_nodes" {
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

variable "dedi_control_plane_pool" {
  description = "list of additional control plane nodes"
  type = list(object({
    name         = string
    ipv4_address = string
    labels       = list(string)
    taints       = list(string)
  }))
  default = []  
}

variable "cloud_workers" {
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

variable "dedi_workers" {
  description = "list of additional worker nodes"
  type = list(object({
    name         = string
    ipv4_address = string
    labels       = list(string)
    taints       = list(string)
  }))
  default = [] 
}
