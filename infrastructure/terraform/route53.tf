locals {
  domain_base = "zipper.aws-sup.development.firemind.io"
  dns_zone    = "development.firemind.io"

  domains = var.STAGE != "production" ? [
    "${var.STAGE}.${var.SERVICE}.${local.domain_base}"
  ] : [
    "${var.STAGE}.${var.SERVICE}.${local.domain_base}",
    "${var.SERVICE}.${local.domain_base}"
  ]
}

data aws_route53_zone primary {
  # name          = "${data.aws_ssm_parameter.zone_name.value}."
  name          = local.dns_zone
  private_zone  = false
}

resource aws_route53_record www_a {
  count   = (length(local.domains))
  name    = local.domains[count.index]
  type    = "A"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}


resource aws_route53_record www_aaaa {
  count   = (length(local.domains))
  name    = local.domains[count.index]
  type    = "AAAA"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}


resource aws_route53_record apigw_a {
  name    = local.api_gateway_domain
  type    = "A"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
  }
}

resource aws_route53_record apigw_aaaa {
  name    = local.api_gateway_domain
  type    = "AAAA"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
  }
}
