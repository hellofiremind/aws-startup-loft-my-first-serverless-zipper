#tfsec:ignore:AWS002 tfsec:ignore:AWS017
resource aws_s3_bucket input_bucket {
  bucket_prefix = "${var.SERVICE}-${var.STAGE}-input"
  tags          = local.common_tags
}

resource "aws_s3_bucket_acl" "input_bucket_acl" {
  bucket = aws_s3_bucket.input_bucket.id
  acl    = "private"
}

resource aws_s3_bucket_public_access_block input_bucket {
  bucket = aws_s3_bucket.input_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_cors_configuration input_bucket {
  bucket = aws_s3_bucket.input_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://localhost:4000", "https://${local.domains[0]}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource aws_s3_bucket_policy input_bucket_policy {
  bucket = aws_s3_bucket.input_bucket.id
  policy = data.aws_iam_policy_document.input_bucket_policy_document.json
}

data aws_iam_policy_document input_bucket_policy_document {
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
      aws_s3_bucket.input_bucket.arn,
      "${aws_s3_bucket.input_bucket.arn}/*"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "input" {
  bucket = aws_s3_bucket.input_bucket.id

    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id   = aws_kms_key.input_bucket_key.arn
        sse_algorithm       = "aws:kms"
      }
    }
}

resource aws_kms_key input_bucket_key {
  description               = "${var.SERVICE}-${var.STAGE}-input-bucket"
  deletion_window_in_days   = 10
  enable_key_rotation       = true
}

resource aws_kms_alias input_bucket_key {
  name                      = "alias/${var.SERVICE}-${var.STAGE}-input-bucket"
  target_key_id             = aws_kms_key.input_bucket_key.key_id

}

output s3_bucket_input {
  value      = join("", aws_s3_bucket.input_bucket.*.id)

  depends_on = [
    aws_s3_bucket.input_bucket
  ]
}
