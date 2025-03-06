resource "hcloud_ssh_key" "main" {
  for_each = var.ssh_keys

  name       = each.key
  public_key = each.value
}

locals {
  nodes = {
    for k in var.nodes : k => {
      meta = {
        name   = k
        domain = "next.id.tjo.space"
      }
    }
  }
}

resource "hcloud_server" "main" {
  for_each = local.nodes

  name = "${each.value.meta.name}.${each.value.meta.domain}"

  image       = "ubuntu-24.04"
  server_type = "cax11"
  datacenter  = "hel1-dc2"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  backups  = true
  ssh_keys = [for key, value in var.ssh_keys : hcloud_ssh_key.main[key].id]

  user_data = <<-EOF
    #cloud-config
    hostname: "${each.value.meta.name}"
    fqdn: "${each.value.meta.name}.${each.value.meta.domain}"
    prefer_fqdn_over_hostname: true
    write_files:
    - path: /etc/tjo.space/meta.json
      encoding: base64
      content: ${base64encode(jsonencode(each.value.meta))}
    packages:
      - git
      - curl
    package_update: true
    package_upgrade: true
    power_state:
      mode: reboot
    swap:
      filename: /swapfile
      size: 512M
    runcmd:
      - "curl -sL https://raw.githubusercontent.com/tjo-space/tjo-space-infrastructure/refs/heads/main/id.tjo.space/install.sh | bash"
    EOF
}

resource "dnsimple_zone_record" "a" {
  for_each = local.nodes

  zone_name = "tjo.space"
  name      = trimsuffix(each.value.meta.domain, ".tjo.space")
  value     = hcloud_server.main[each.key].ipv4_address
  type      = "A"
  ttl       = 300
}

# Podman is PITA!
#resource "dnsimple_zone_record" "aaaa" {
#  for_each = local.nodes
#
#  zone_name = "tjo.space"
#  name      = trimsuffix(each.value.meta.domain, ".tjo.space")
#  value     = hcloud_server.main[each.key].ipv6_address
#  type      = "AAAA"
#  ttl       = 300
#}
