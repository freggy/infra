resource "hcloud_server" "server" {
  count       = var.is_hcloud_server ? 1 : 0
  name        = var.hcloud_name
  //image     = var.microos_snapshot_id
  server_type = var.hcloud_server_type
  location    = var.hcloud_location
  ssh_keys    = var.hcloud_ssh_keys
}

