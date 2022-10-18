#tfsec:ignore:AWS002
resource aws_s3_bucket serverless_bucket {
  bucket_prefix             = "${var.SERVICE}-${var.STAGE}-serverless"
  tags                      = local.common_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "serverless" {
  bucket = aws_s3_bucket.serverless_bucket.id

    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id   = aws_kms_key.deployment_key.arn
        sse_algorithm       = "aws:kms"
      }
    }
}

resource "aws_s3_bucket_acl" "serverless_bucket_acl" {
  bucket = aws_s3_bucket.serverless_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "serverless_versioning" {
  bucket = aws_s3_bucket.serverless_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource aws_s3_bucket_public_access_block serverless_bucket {
  bucket                    = aws_s3_bucket.serverless_bucket.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}

resource aws_kms_key deployment_key {
  description               = "${var.SERVICE}-${var.STAGE}-deployment"
  deletion_window_in_days   = 10
  enable_key_rotation       = true
}

resource aws_kms_alias deployment_key {
  name                      = "alias/${var.SERVICE}-${var.STAGE}-deployment"
  target_key_id             = aws_kms_key.deployment_key.key_id
}

resource aws_s3_bucket_policy serverless_bucket_policy {
  bucket                    = aws_s3_bucket.serverless_bucket.id
  policy                    = data.aws_iam_policy_document.serverless_bucket_policy_document.json
}

data aws_iam_policy_document serverless_bucket_policy_document {
  statement {
    sid                     = "EnforceHttpsAlways"
    effect                  = "Deny"

    principals {
      type                  = "*"
      identifiers           = ["*"]
    }

    actions                 = [
      "*"
    ]

    resources               = [
      aws_s3_bucket.serverless_bucket.arn,
      "${aws_s3_bucket.serverless_bucket.arn}/*"
    ]

    condition {
      test                  = "Bool"
      variable              = "aws:SecureTransport"
      values                = [
        "false"
      ]
    }
  }

}

output serverless_s3_bucket {
  value      = join("", aws_s3_bucket.serverless_bucket.*.id)

  depends_on = [
    aws_s3_bucket.serverless_bucket
  ]
}
