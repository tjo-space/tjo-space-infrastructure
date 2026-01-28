output "nodes" {
  value = [
    for key, node in local.nodes_deployed : {
      name = node.name
      fqdn = node.fqdn
      ipv6 = node.private_ipv6
    }
  ]
}
