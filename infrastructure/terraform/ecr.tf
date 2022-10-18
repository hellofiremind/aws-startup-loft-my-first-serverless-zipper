resource "aws_ecr_repository" "zip_service_repo" {
  name                 = "${var.SERVICE}-${var.STAGE}-zip-service-repository"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_alias.zip_service_repo_alias.target_key_arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_kms_key" "zip_service_repo" {
  description             = "ECR Repo KMS key with alias"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "zip_service_repo_alias" {
  name          = "alias/${var.SERVICE}-${var.STAGE}-zip-service-repository"
  target_key_id = aws_kms_key.zip_service_repo.key_id
}

data aws_iam_policy_document ecr_kms_key_policy {
  statement {
    sid = "AllowKeyManagementOps"

    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam:${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "AllowKeyUsageByServices"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:RetireGrant"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["ecr.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

output ecr_repository_url {
  value = aws_ecr_repository.zip_service_repo.repository_url
}
