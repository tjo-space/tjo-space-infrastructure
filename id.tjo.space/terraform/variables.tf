variable "hcloud_token" {
  sensitive = true
  type = string
}

variable "dnsimple_token" {
  sensitive = true
  type = string
}

variable "dnsimple_account_id" {
  type = string
}

variable "ssh_keys" {
  type = map(string)
}

variable "nodes" {
  type = list(string)
}
