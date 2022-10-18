resource aws_cloudfront_origin_access_identity site_origin_access_identity {
  comment = "${var.SERVICE} ${var.STAGE} Origin Access Identity"
}

locals {
  frontend_origin_id = "FrontendOrigin"
}

#tfsec:ignore:AWS045
resource aws_cloudfront_distribution site {
  comment = "${var.SERVICE} ${var.STAGE} site"
  
  depends_on  = [
    module.cloudfront_certificate,
    aws_s3_bucket.site_bucket
  ]

  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id   = local.frontend_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.site_origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.frontend_origin_id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["session"]
      }
    }
  }


  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["ET"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.cloudfront_certificate.certificate_arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
    # cloudfront_default_certificate = true
  }

  price_class         = "PriceClass_All"
  aliases             = local.domains
  enabled             = true
  is_ipv6_enabled     = true

  # web_acl_id          = module.waf_global.web_acl_arn

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging_bucket.bucket_domain_name
    prefix          = "cloudfront/${local.domains[0]}/"
  }

  default_root_object = "index.html"
  wait_for_deployment = false

  tags                = local.common_tags
}

output site_distribution_id {
  value = aws_cloudfront_distribution.site.id
}
