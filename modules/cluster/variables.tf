variable "kubernetes_version" {
  description = ""
  type = string
}

variable "ssh_private_key" {
  description = ""
  type = string
}

variable "cloud_control_plane_pools" {
  description = "configuration of cloud control plane node pools"
  type = list(object({
    name                       = string
    server_type                = string
    location                   = string
    labels                     = list(string)
    taints                     = list(string)
    initial_ssh_keys           = list(string)
    count                      = number
  }))
  default = []
}

variable "cloud_worker_pools" {
  description = "configuration of cloud worker node pools"
  type = list(object({
    name                       = string
    server_type                = string
    location                   = string
    labels                     = list(string)
    taints                     = list(string)
    initial_ssh_keys           = list(string)
    count                      = number
  }))
  default = []
}

// those are to support dedicated servers, from hetzner server auction for example

variable "dedi_control_plane_pool" {
  description = "list of additional control plane nodes"
  type = list(object({
    ipv4_address   = string
    labels = list(string)
    taints = list(string)
  }))
  default = []  
}

variable "dedi_worker_pool" {
  description = "list of additional worker nodes"
  type = list(object({
    ipv4_address   = string
    labels = list(string)
    taints = list(string)
  }))
  default = [] 
}
