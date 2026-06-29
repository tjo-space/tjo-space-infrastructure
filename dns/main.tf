data "dns_a_record_set" "ingress" {
  host = "any.ingress.tjo.cloud"
}
data "dns_aaaa_record_set" "ingress" {
  host = "any.ingress.tjo.cloud"
}

# List of subdomains that are routed via ingress.
resource "desec_rrset" "ingress" {
  for_each = { for pair in setproduct(["A", "AAAA"], [
    "",
    "cloud",
    "collabora",
    "code",
    "chat",
    "turn.chat",
    "mas.chat",
    "matrix.chat",
    "webhook.chat",
    "*.media",
    "media",
    "paperless",
    "photos",
    "rss",
    "search",
    "vault",
  ]) : "${pair[0]}-${pair[1]}" => { type = pair[0], subname = pair[1] } }

  domain  = "tjo.space"
  subname = each.value.subname
  type    = each.value.type
  records = each.value.type == "A" ? data.dns_a_record_set.ingress.addrs : data.dns_aaaa_record_set.ingress.addrs
  ttl     = 3600
}
resource "desec_rrset" "https" {
  for_each = toset([
    "",
    "cloud",
    "collabora",
    "code",
    "chat",
    "turn.chat",
    "mas.chat",
    "matrix.chat",
    "webhook.chat",
    "*.media",
    "media",
    "paperless",
    "photos",
    "rss",
    "search",
    "vault",
  ])

  domain  = "tjo.space"
  subname = each.value
  type    = "HTTPS"
  records = ["0 any.ingress.tjo.cloud."]
  ttl     = 3600
}

locals {
  records = [
    { type = "CNAME", subdomain = "id", records = ["id.tjo.cloud."] },
    { type = "CNAME", subdomain = "status", records = ["tjo-space.github.io."] },
  ]
}
resource "desec_rrset" "records" {
  for_each = { for record in local.records : "${record.type}-${record.subdomain}" => record }

  domain  = "tjo.space"
  subname = each.value.subdomain
  type    = each.value.type
  # We must wrap TXT records with quotes (")
  records = each.value.type == "TXT" ? [for record in each.value.records : "\"${record}\""] : each.value.records
  ttl     = 3600
}
