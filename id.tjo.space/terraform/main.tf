resource "hcloud_ssh_key" "main" {
  for_each   = var.ssh_keys

  name       = each.key
  public_key = each.value
}

resource "hcloud_server" "main" {
  for_each = toset(var.nodes)

  name        = "${each.key}.id.tjo.space"

  image       = "ubuntu-24.04"
  server_type = "cax11"

  datacenter = "hel1-dc2"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  backups = true

  ssh_keys = [for key, value in var.ssh_keys : hcloud_ssh_key.main[key].id]

  user_data = <<-EOF
    #cloud-config
    hostname: "${each.key}"
    fqdn: id.tjo.space
    prefer_fqdn_over_hostname: true
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
  for_each = toset(var.nodes)

  zone_name = "tjo.space"
  name      = "next.id"
  value     = hcloud_server.main[each.key].ipv4_address
  type      = "A"
  ttl       = 300
}

resource "dnsimple_zone_record" "aaaa" {
  for_each = toset(var.nodes)

  zone_name = "tjo.space"
  name      = "next.id"
  value     = hcloud_server.main[each.key].ipv6_address
  type      = "AAAA"
  ttl       = 300
}
