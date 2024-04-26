variable "kubernetes_version" {
  description = ""
  type = string
}

variable "ssh_private_key" {
  description = ""
  type = string
}

variable "cloud_control_plane_nodepools" {
  description = "configuration of cloud control plane node pools"
  type = list(object({
    name                       = string
    server_type                = string
    location                   = string
    labels                     = list(string)
    taints                     = list(string)
    ssh_keys                   = list(string)
    count                      = number
  }))
  default = []
}

variable "cloud_worker_nodepools" {
  description = "configuration of cloud worker node pools"
  type = list(object({
    name                       = string
    server_type                = string
    location                   = string
    labels                     = list(string)
    taints                     = list(string)
    ssh_keys                   = list(string)
    count                      = number
  }))
  default = []
}

// those are to support dedicated servers, from hetzner server auction for example

variable "additional_control_plane_addrs" {
  description = "list of additional control plane addresses"
  type = list(object({
    addr   = string
    labels = list(string)
    taints = list(string)
  }))
  default = []  
}

variable "additional_worker_addrs" {
  description = "list of additional worker addresses"
  type = list(object({
    addr   = string
    labels = list(string)
    taints = list(string)
  }))
  default = [] 
}
