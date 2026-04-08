variable "domain" {
  type    = string
  default = "code.tjo.space"
}

variable "authentik_token" {
  type      = string
  sensitive = true
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

variable "nodes" {
  type = map(object({
    host         = string
    cores        = optional(number, 2)
    memory       = optional(number, 2048)
    boot_storage = string
    boot_size    = optional(number, 24)

    data_storage = string
    data_size    = number
  }))
}

variable "dns_tjo_cloud_token" {
  type      = string
  sensitive = true
}
