output "ipv4_address" {
    // hacky workaround, because we cannot have
    // a conditional return e.g.
    // if var.ipv4_address != null then return var.ipv4_address
    //
    // take any that is not null or empty empty.
    // if both are present hcloud_server.ipv4_address
    // will be preferred.
    value = coalesce(hcloud_server.server[0].ipv4_address, var.ipv4_address)
}