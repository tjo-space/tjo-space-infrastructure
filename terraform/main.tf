resource "hcloud_ssh_key" "main" {
  for_each   = var.ssh_keys
  name       = each.key
  public_key = eeach.value
}

resource "hcloud_server" "main" {
  name        = "id.tjo.space"
  image       = "ubuntu-24.04"
  server_type = "cax11"

  datacenter = "hel1-dc2"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  backups = true

  ssh_keys = [for key in var.ssh_keys : hcloud_ssh_key.main[key].id]

  user_data = <<-EOF
    #cloud-config
    hostname: id
    fqdn: id.tjo.space
    prefer_fqdn_over_hostname: true
    packages:
      - git
    package_update: true
    package_upgrade: true
    power_state:
      mode: reboot
    swap:
      filename: /swapfile
      size: 512M
    runcmd:
      - su ubuntu -c "git clone --depth 1 git@github.com:tjo-space/infrastructure-ng.git /home/ubuntu/service"
      - su ubuntu -c "/home/ubuntu/service/install.sh"
  EOF
}

resource "dnsimple_zone_record" "a" {
  zone_name = "tjo.space"
  name      = "id.tjo.space"
  value     = hcloud_server.main.ipv4_address
  type      = "A"
  ttl       = 300
}

resource "dnsimple_zone_record" "aaaa" {
  zone_name = "tjo.space"
  name      = "id.tjo.space"
  value     = hcloud_server.main.ipv6_address
  type      = "AAAA"
  ttl       = 300
}
