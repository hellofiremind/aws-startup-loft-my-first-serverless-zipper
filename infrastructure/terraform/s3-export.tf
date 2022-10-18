#tfsec:ignore:AWS002 tfsec:ignore:AWS017
resource aws_s3_bucket export_bucket {
  bucket_prefix = "${var.SERVICE}-${var.STAGE}-export"
  tags          = local.common_tags
}

resource "aws_s3_bucket_acl" "export_bucket_acl" {
  bucket = aws_s3_bucket.export_bucket.id
  acl    = "private"
}

resource aws_s3_bucket_public_access_block export_bucket {
  bucket = aws_s3_bucket.export_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_policy export_bucket_policy {
  bucket = aws_s3_bucket.export_bucket.id
  policy = data.aws_iam_policy_document.export_bucket_policy_document.json
}

resource aws_s3_bucket_lifecycle_configuration delete_old_exports {
  bucket = aws_s3_bucket.export_bucket.id

  rule {
    expiration {
      days = 2
    }

    status  = "Enabled"
    id      = "delete_old_exports"
  }
}

data aws_iam_policy_document export_bucket_policy_document {
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
      aws_s3_bucket.export_bucket.arn,
      "${aws_s3_bucket.export_bucket.arn}/*"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "export" {
  bucket = aws_s3_bucket.export_bucket.id

    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id   = aws_kms_key.export_bucket_key.arn
        sse_algorithm       = "aws:kms"
      }
    }
}

resource aws_kms_key export_bucket_key {
  description               = "${var.SERVICE}-${var.STAGE}-export-bucket"
  deletion_window_in_days   = 10
  enable_key_rotation       = true
}

resource aws_kms_alias export_bucket_key {
  name                      = "alias/${var.SERVICE}-${var.STAGE}-export-bucket"
  target_key_id             = aws_kms_key.export_bucket_key.key_id
}

output s3_bucket_export {
  value      = join("", aws_s3_bucket.export_bucket.*.id)

  depends_on = [
    aws_s3_bucket.export_bucket
  ]
}
