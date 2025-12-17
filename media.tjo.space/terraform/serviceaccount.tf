data "authentik_group" "monitoring_publisher" {
  name          = "cloud.tjo.monitor/publisher"
  include_users = false
}

resource "authentik_user" "service_account" {
  for_each = local.nodes_with_name

  username = each.value.fqdn
  name     = each.value.fqdn

  type = "service_account"
  path = var.domain

  groups = [
    data.authentik_group.monitoring_publisher.id,
  ]
}

resource "authentik_token" "service_account" {
  for_each = local.nodes_with_name

  identifier   = replace("service-account-${each.value.fqdn}", ".", "-")
  user         = authentik_user.service_account[each.key].id
  description  = "Service account for ${each.value.fqdn} node."
  expiring     = false
  intent       = "app_password"
  retrieve_key = true
}
