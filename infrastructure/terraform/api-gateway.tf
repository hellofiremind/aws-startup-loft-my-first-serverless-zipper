locals {
  api_gateway_domain = "api.${local.domains[0]}"
  api_gateway_security_policy = "TLS_1_2"
}

resource aws_api_gateway_rest_api main_api {
  name = "${var.SERVICE}-${var.STAGE}"

  minimum_compression_size = 0

 endpoint_configuration {
    types = ["EDGE"]
  }
}

resource aws_api_gateway_domain_name api {

  depends_on  = [
    module.cloudfront_certificate
  ]

  certificate_arn = module.cloudfront_certificate.certificate_arn
  domain_name     = local.api_gateway_domain

  security_policy = local.api_gateway_security_policy
}

resource aws_api_gateway_base_path_mapping api {
  api_id      = aws_api_gateway_rest_api.main_api.id
  domain_name = aws_api_gateway_domain_name.api.domain_name
  stage_name  = var.STAGE
}

output api_gateway_rest_api_id {
  value = aws_api_gateway_rest_api.main_api.id
}

output api_gateway_root_resource_id {
  value = aws_api_gateway_rest_api.main_api.root_resource_id
}
