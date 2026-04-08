locals {
  nodes_with_name = {
    for k, v in var.nodes : k => merge(v, {
      name = k
      fqdn = "${k}.${var.domain}"
    })
  }

  nodes_with_meta = {
    for k, v in local.nodes_with_name : k => merge(v, {
      meta = {
        cloud_provider = "proxmox"
        service_name   = var.domain
        service_account = {
          username = authentik_user.service_account[k].username
          password = authentik_token.service_account[k].key
        }
      }
    })
  }

  nodes_deployed = {
    for k, v in local.nodes_with_meta : k => merge(v, {
      private_ipv6 = module.proxmox_node[k].address.ipv6
    })
  }

  global = yamldecode(file("../../${path.module}/global.yaml"))
}

module "proxmox_node" {
  source   = "../../shared/terraform/modules/proxmox"
  for_each = local.nodes_with_meta

  name        = each.value.name
  fqdn        = each.value.fqdn
  description = "code.tjo.cloud node ${each.value.name}"
  host        = each.value.host

  cores  = each.value.cores
  memory = each.value.memory

  boot = {
    storage = each.value.boot_storage
    size    = each.value.boot_size
    image   = "debian_13_server_cloudimg_amd64.img"
  }

  disks = [
    {
      storage = each.value.data_storage
      size    = each.value.data_size
      index   = 1
    },
  ]

  userdata = {
    disk_setup = {
      "/dev/vdb" = {
        table_type = "gpt"
        layout     = [100]
      }
    }
    fs_setup = [
      {
        label      = "data"
        filesystem = "ext4"
        device     = "/dev/vdb"
      },
    ]
    mounts = [
      ["/dev/vdb1", "/srv/data"],
    ]
  }
  metadata = each.value.meta

  ssh_keys = local.global.tjo_space_admin_ssh_keys
  tags     = ["code.tjo.space", "tjo.space"]
}

resource "local_file" "ansible_inventory" {
  content = yamlencode({
    all = {
      hosts = {
        for k, v in local.nodes_deployed : v.fqdn => {
          ansible_host   = v.private_ipv6
          ansible_port   = 2222
          ansible_user   = "bine"
          ansible_become = true
        }
      }
    }
  })
  filename = "${path.module}/../ansible/inventory.yaml"
}

resource "local_file" "ansible_vars" {
  content  = yamlencode({})
  filename = "${path.module}/../ansible/vars.terraform.yaml"
}

resource "technitium_record" "root" {
  for_each   = local.nodes_deployed
  zone       = "space.internal"
  domain     = "code.space.internal"
  ttl        = 60
  type       = "AAAA"
  ip_address = each.value.private_ipv6
}

resource "technitium_record" "for_node" {
  for_each   = local.nodes_deployed
  zone       = "space.internal"
  domain     = "${each.value.name}.code.space.internal"
  ttl        = 60
  type       = "AAAA"
  ip_address = each.value.private_ipv6
}
