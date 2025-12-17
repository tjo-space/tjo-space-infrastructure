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
        cloud_provider = v.provider
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
      private_ipv4 = module.proxmox_node[k].address.ipv4
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
  description = "media.tjo.cloud node ${each.value.name}"
  host        = each.value.host

  cores  = each.value.cores
  memory = each.value.memory

  boot = {
    storage = each.value.boot_storage
    size    = each.value.boot_size
    image   = "ubuntu_2404_server_cloudimg_amd64.img"
  }

  disks = [
    {
      storage = each.value.data_large_storage
      size    = each.value.data_large_size
    },
    {
      storage = each.value.data_fast_storage
      size    = each.value.data_fast_size
    },
  ]

  userdata = {
    disk_setup = {
      "/dev/vdb" = {
        table_type = "gpt"
        layout     = [100]
      }
      "/dev/vdc" = {
        table_type = "gpt"
        layout     = [100]
      }
    }
    fs_setup = [
      {
        label      = "datalarge"
        filesystem = "ext4"
        device     = "/dev/vdb"
      },
      {
        label      = "datafast"
        filesystem = "ext4"
        device     = "/dev/vdc"
      },
    ]
    mounts = [
      ["/dev/vdb1", "/srv/data/large"],
      ["/dev/vdc1", "/srv/data/fast"],
    ]
  }
  metadata = each.value.meta

  ssh_keys = local.global.tjo_space_admin_ssh_keys
  tags     = ["media.tjo.space"]
}

resource "local_file" "ansible_inventory" {
  content = yamlencode({
    all = {
      hosts = {
        for k, v in local.nodes_deployed : v.fqdn => {
          ansible_host   = v.private_ipv4
          ansible_port   = 2222
          ansible_user   = "bine"
          ansible_become = true
          provider       = v.provider
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
