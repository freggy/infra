variable "is_dedi_server" {
  type = bool
  default = false
}

variable "addr" {
  type = string
  default = ""
}

variable "is_hcloud_server" {
  type = bool
  default = false
}

variable "hcloud_server_type" {
  type = string
  default = ""
}

variable "hcloud_name" {
  type = string
  default = ""
}

variable "hcloud_location" {
  type = string // maybe enum???
  default = "fsn1"
}

variable "hcloud_ssh_keys" {
  type = list(string)
  default = []
}