data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    sid = "XrayPutTrace"

    actions = [
      "xray:PutTraceSegments",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "DynamoDB"

    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:DeleteItem"
    ]

    resources = concat(var.DYNAMODB_TABLES, [for table in var.DYNAMODB_TABLES : "${table}*"])
  }

  statement {
    sid = "KMS"

    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = compact(var.KMS_KEYS)
  }

  statement {
    sid = "SQS"

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]

    resources = concat(var.SQS_QUEUES, [for queue in var.SQS_QUEUES : "${queue}*"])
  }

  statement {
    sid = "S3"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = concat(compact(var.S3_BUCKETS), [for bucket in compact(var.S3_BUCKETS) : "${bucket}/*"])
  }

  statement {
    sid = "SSM"

    actions = [
      "ssm:Get*",
      "ssm:Describe*"
    ]

    resources = [
      "arn:aws:logs:${var.REGION}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.SERVICE}-${var.STAGE}*:*",
      "arn:aws:ssm:${var.REGION}:${data.aws_caller_identity.current.account_id}:parameter/${var.SERVICE}/${var.STAGE}/*"
    ]
  }

  statement {
    sid = "CloudwatchLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.REGION}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.SERVICE}-${var.STAGE}*:*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_trust_relationship_policy" {
  statement {
    sid = "AllowLambda"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource aws_iam_role lambda_role {
  name                = "${var.SERVICE}-${var.STAGE}-lambda"
  assume_role_policy  = data.aws_iam_policy_document.lambda_trust_relationship_policy.json
  tags                = var.TAGS
}

resource aws_iam_policy lambda_policy {
  name        = "${var.SERVICE}-${var.STAGE}-lambda"
  description = "${var.SERVICE}-${var.STAGE}-lambda"
  policy      = data.aws_iam_policy_document.lambda_role_policy.json
}

resource aws_iam_role_policy_attachment lambda_role {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource aws_iam_role_policy_attachment lambda_role_ec2_execution {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
