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
    "code",
    "collabora",
    "chat",
    "turn.chat",
    "mas.chat",
    "matrix.chat",
    "webhook.chat",
    "*.media",
    "media",
    "paperless",
    "rss",
    "search",
    "send",
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
    "code",
    "collabora",
    "chat",
    "turn.chat",
    "mas.chat",
    "matrix.chat",
    "webhook.chat",
    "*.media",
    "media",
    "paperless",
    "rss",
    "search",
    "send",
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
    ## Id
    { type = "CNAME", subdomain = "id", records = ["id.tjo.cloud."] },
    { type = "CNAME", subdomain = "status", records = ["tjo-space.github.io."] },
    ## EMAIL
    { type = "MX", subdomain = "", records = ["10 mail.tjo.cloud."] },
    { type = "TXT", subdomain = "202507e._domainkey", records = ["v=DKIM1; k=ed25519; h=sha256; p=QWivDgL9vFoPzbYmdQagOR/OnNr8gLRu1bTTszIqfJA="] },
    { type = "TXT", subdomain = "202507r._domainkey", records = ["v=DKIM1; k=rsa; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2F1gjOzE6f8Rurvtdy/B6Xs2zhGZdtZ3YFfP/LpwN2aVjBVASGUXFhjv24hGulfJAyE28MNDXem3xvNjD1UFFyctuplp2CALSlElEb0AcAnoC3tgD0QEPlS3fkEqJ9QEctH/QG0qISUYxGqvispKRCIWKzVPo1zzGIL/Zasdh0RSorizhYwt548FH+e/g70HHtj1LPBbow2C304wbmQ7UMeOfoKGO0pidtX0Ic/eMz7PJH4JSer9UsFf1s4rkWNjw7/Q2mpay+BSZnLkYe5+ucuuZmHYUMFKHKot9DQ3p2vFUMQaIVSo/Yv7FQvSM6b2KG0pp7cDZx5XOzLkUVjKMwIDAQAB"] },
    { type = "TXT", subdomain = "", records = [
      "v=spf1 mx ra=postmaster -all",
      "google-site-verification=oDVJ2M9VSmYlEOFOSrg74kTeVigpkUQS6BP0f_zOeww",
    ] },
    { type = "SRV", subdomain = "_jmap._tcp", records = ["0 1 443 mail.tjo.cloud."] },
    { type = "SRV", subdomain = "_calddavs._tcp", records = ["0 1 443 mail.tjo.cloud."] },
    { type = "SRV", subdomain = "_carddavs._tcp", records = ["0 1 443 mail.tjo.cloud."] },
    { type = "SRV", subdomain = "_imaps._tcp", records = ["0 1 443 mail.tjo.cloud."] },
    { type = "SRV", subdomain = "_submissions._tcp", records = ["0 1 443 mail.tjo.cloud."] },
    { type = "CNAME", subdomain = "autoconfig", records = ["mail.tjo.cloud."] },
    { type = "CNAME", subdomain = "autodiscover", records = ["mail.tjo.cloud."] },
    { type = "CNAME", subdomain = "mta-sts", records = ["mail.tjo.cloud."] },
    { type = "TXT", subdomain = "_mta-sts", records = ["v=STSv1; id=12389896138107905122"] },
    { type = "TXT", subdomain = "_dmarc", records = ["v=DMARC1; p=reject; rua=mailto:postmaster@tjo.space; ruf=mailto:postmaster@tjo.space"] },
    { type = "TXT", subdomain = "_smtp._tls", records = ["v=TLSRPTv1; rua=mailto:postmaster@tjo.space"] },
    ## SYSTEM
    { type = "A", subdomain = "batuu.system", records = ["100.65.175.106"] },
    { type = "A", subdomain = "nevaroo.system", records = ["100.69.126.80"] },
    { type = "AAAA", subdomain = "batuu.system", records = ["fd7a:115c:a1e0::b01:af6a"] },
    { type = "AAAA", subdomain = "nevaroo.system", records = ["fd7a:115c:a1e0::6501:7e50"] },
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
