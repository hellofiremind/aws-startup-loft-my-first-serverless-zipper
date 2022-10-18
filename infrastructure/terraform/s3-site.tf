#tfsec:ignore:AWS002 tfsec:ignore:AWS017
resource aws_s3_bucket site_bucket {
  bucket_prefix = "${var.SERVICE}-${var.STAGE}-site"
  tags          = local.common_tags
}

resource "aws_s3_bucket_acl" "site_bucket_acl" {
  bucket = aws_s3_bucket.site_bucket.id
  acl    = "private"
}

resource aws_s3_bucket_public_access_block site_bucket {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_policy site_bucket_policy {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.site_bucket_policy_document.json
}

data aws_iam_policy_document site_bucket_policy_document {

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.site_origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.site_origin_access_identity.iam_arn]
    }
  }

  statement {
    sid       = "EnforceHttpsAlways"
    effect    = "Deny"

    principals {
      type = "*"
      identifiers = ["*"]
    }

    actions   = [
      "*"
    ]

    resources = [
      aws_s3_bucket.site_bucket.arn,
      "${aws_s3_bucket.site_bucket.arn}/*"
    ]

    condition {
      test       = "Bool"
      variable   = "aws:SecureTransport"
      values     = [
        "false"
      ]
    }
  }

}


output s3_bucket_site {
  value      = join("", aws_s3_bucket.site_bucket.*.id)

  depends_on = [
    aws_s3_bucket.site_bucket
  ]
}
