output "ipv4" {
  value = { for node in var.nodes : node => hcloud_server.main[node].ipv4_address }
}

output "ipv6" {
  value = { for node in var.nodes : node => hcloud_server.main[node].ipv6_address }
}
