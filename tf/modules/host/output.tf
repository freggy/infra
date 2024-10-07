/*
output "ipv4_address" {
  // hacky workaround, because we cannot have a conditional return e.g.
  // if var.ipv4_address != null then return var.ipv4_address
  //
  // try get hcloud_server ipv4 if this does not work return ipv4_address
  // if both are present hcloud_server.ipv4_address will be preferred.
  value = try(hcloud_server.server[0].ipv4_address, var.ipv4_address)
}*/

output "tailscale_ipv4_address" {
  // in the case of a dedicated server var.ipv4_address is the internal IP
  value = try(module.tailscale_device[0].tailscale_ipv4_address, var.ipv4_address)
}

output "name" {
  value = var.name
}
