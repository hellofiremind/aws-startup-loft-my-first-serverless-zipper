locals {
  certificate_domains     = concat(local.domains, [local.api_gateway_domain])
  cert_domains_zones = [for value in local.certificate_domains : {
    zone = local.dns_zone
    domain = value
  }]
}

module cloudfront_certificate {
  source  = "./modules/acm-certificate"

  providers = {
    aws = aws.north_virginia
  }

  domain_name = {
    zone = local.cert_domains_zones[0].zone
    domain = local.cert_domains_zones[0].domain
  }

  subject_alternative_names = slice(local.cert_domains_zones, 1, length(local.cert_domains_zones))
  tags = local.common_tags
}

