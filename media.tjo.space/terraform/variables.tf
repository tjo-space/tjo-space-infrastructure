variable "domain" {
  type    = string
  default = "media.tjo.space"
}

variable "authentik_token" {
  type      = string
  sensitive = true
}

variable "desec_token" {
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
    memory       = optional(number, 4096)
    boot_storage = string
    boot_size    = optional(number, 8)

    data_fast_storage = string
    data_fast_size    = number

    data_large_storage = string
    data_large_size    = number

    data_ephemeral_storage = string
    data_ephemeral_size    = number
  }))
}
