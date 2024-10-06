output "tailscale_auth_key" {
  value = tailscale_tailnet_key.auth_key.key
}

output "tailscale_ipv4_address" {
  value = sort(data.tailscale_device.device.addresses)[0]
}
