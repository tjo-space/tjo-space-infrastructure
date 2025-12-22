data "authentik_flow" "ldap-authentication-flow" {
  slug = "ldap-authentication-flow"
}
data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}
data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}
data "authentik_flow" "default-invalidation-flow" {
  slug = "default-invalidation-flow"
}

// User Access
// Uses LDAP authentication.
resource "authentik_provider_ldap" "users" {
  name        = "ng.media.tjo.space"
  base_dn     = "dc=media,dc=tjo,dc=space"
  bind_flow   = data.authentik_flow.ldap-authentication-flow.id
  unbind_flow = data.authentik_flow.default-invalidation-flow.id
  bind_mode   = "direct"
  search_mode = "cached"
}
resource "authentik_application" "users" {
  name              = "ng.media.tjo.space"
  slug              = "ngmediatjospace"
  protocol_provider = authentik_provider_ldap.users.id
}
resource "authentik_rbac_permission_user" "ldap" {
  for_each = local.nodes_with_name

  user       = authentik_user.service_account[each.key].id
  model      = "authentik_providers_ldap.ldapprovider"
  permission = "search_full_directory"
  object_id  = authentik_provider_ldap.users.id
}
resource "authentik_outpost" "ldap" {
  name = "media.tjo.space/ldap"
  type = "ldap"
  protocol_providers = [
    authentik_provider_ldap.users.id
  ]
}

// Management
// Uses Proxy authentication.
resource "authentik_provider_proxy" "admins" {
  name               = "manage.ng.media.tjo.space"
  external_host      = "https://ng.media.tjo.space"
  cookie_domain      = "ng.media.tjo.space"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.default-provider-invalidation-flow.id
  mode               = "forward_domain"
}
resource "authentik_application" "admins" {
  name              = "manage.ng.media.tjo.space"
  slug              = "managemediatjospace"
  protocol_provider = authentik_provider_proxy.admins.id
}
resource "authentik_outpost" "admins" {
  name = "media.tjo.space/proxy"
  type = "proxy"
  protocol_providers = [
    authentik_provider_proxy.admins.id
  ]
}
