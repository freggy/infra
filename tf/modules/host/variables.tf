variable "name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "kubernetes_major_version" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "environment" {
  type = string
}

/*
 * dedicated server properties
 */

variable "is_dedi_server" {
  type    = bool
  default = false
}

variable "ipv4_address" {
  type    = string
  default = ""
}

/*
 * hetzner cloud server properties
 */

variable "is_hcloud_server" {
  type    = bool
  default = false
}

variable "hcloud_server_type" {
  type    = string
  default = ""
}

variable "hcloud_location" {
  type    = string
  default = "fsn1"
}

variable "hcloud_image" {
  type    = any
  default = "ubuntu-22.04"
}

variable "hcloud_ssh_keys" {
  type    = list(string)
  default = []
}

variable "hcloud_labels" {
  type    = map(string)
  default = {}
}
