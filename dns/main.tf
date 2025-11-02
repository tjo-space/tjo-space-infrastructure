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
    "books",
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
    "penpot",
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
    { type = "TXT", subdomain = "_mta-sts", records = ["v=STSv1; id=6866269529996095712"] },
    { type = "TXT", subdomain = "_dmarc", records = ["v=DMARC1; p=reject; rua=mailto:postmaster@tjo.space; ruf=mailto:postmaster@tjo.space"] },
    { type = "TXT", subdomain = "_smtp._tls", records = ["v=TLSRPTv1; rua=mailto:postmaster@tjo.space"] },
    { type = "TLSA", subdomain = "_25._tcp.mail", records = [
      "3 0 1 2d210b2bd7e921e1a7fd11a80b527fe84dff45e186535dc0d1fc35e0b84b67cc",
      "3 0 2 d4db783180cf8ecb5cb6e2d72d6f774e293d92c2ac3e92b7068c17c5148f8a7b6eb06bce0f5b861f19ad526e60d37174b5212ed05bb88566752eba83011d3c88",
      "3 1 1 ec5cd6782de55a70ec41bdcebefcac8ee6febd7777f65931fc5679ade6c2b04b",
      "3 1 2 4f8a71b84006c5f7d4d68793aa4bece277e90515ca44eea3ca665f629e8c8ec29df4d58d1bba5101e4746a1061771843a69c16b0b2155a8614a483e59832a438",
      "2 0 1 aeb1fd7410e83bc96f5da3c6a7c2c1bb836d1fa5cb86e708515890e428a8770b",
      "2 0 2 e18f3d6ccbc578f025c3c7c29ed7bffe1b8eef5b1f839c17298dcf218303d2a63e305f6c1f489691774a18bad836035e5af2de1fc42a3a26cfe9e530f92e3855",
      "2 1 1 cbbc559b44d524d6a132bdac672744da3407f12aae5d5f722c5f6c7913871c75",
      "2 1 2 7d779dd26d37ca5a72fd05f1b815a06078c8e09777697c651fbe012c8d2894e048fcfe24160ee1562602240b6bef44e00f2b7340c84546d6110842bbdeb484a7",
    ] },
    ## SYSTEM
    { type = "A", subdomain = "batuu.system", records = ["100.65.175.106"] },
    { type = "A", subdomain = "jakku.system", records = ["100.106.240.50"] },
    { type = "A", subdomain = "nevaroo.system", records = ["100.69.126.80"] },
    { type = "AAAA", subdomain = "batuu.system", records = ["fd7a:115c:a1e0::b01:af6a"] },
    { type = "AAAA", subdomain = "jakku.system", records = ["fd7a:115c:a1e0::2b01:f033"] },
    { type = "AAAA", subdomain = "nevaroo.system", records = ["fd7a:115c:a1e0::6501:7e50"] },
    { type = "A", subdomain = "internal-batuu.system", records = ["10.0.4.1"] },
    { type = "A", subdomain = "internal-jakku.system", records = ["10.0.4.2"] },
    { type = "A", subdomain = "internal-nevaroo.system", records = ["10.0.4.3"] },
    { type = "AAAA", subdomain = "internal-batuu.system", records = ["fd74:6a6f::be24:11ff:fec0:96a6"] },
    { type = "AAAA", subdomain = "internal-jakku.system", records = ["fd74:6a6f::be24:11ff:feda:f12b"] },
    { type = "AAAA", subdomain = "internal-nevaroo.system", records = ["fd74:6a6f::be24:11ff:feb6:43af"] },
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
