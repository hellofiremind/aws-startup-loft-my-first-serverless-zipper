resource aws_ecs_cluster cluster {
  name  = "${var.SERVICE}-${var.STAGE}-zip-service-cluster"
  tags  = local.common_tags
}

resource aws_cloudwatch_log_group zip_service {
  name              = "/ecs/${var.SERVICE}-${var.STAGE}-zip-service-task-logs"
  retention_in_days = 14

  tags              = local.common_tags
}

resource aws_ecs_task_definition zip_service {
  family                   = "${var.SERVICE}-${var.STAGE}-task-definition"
  container_definitions    = templatefile("./task-definition.json", {
    REGION     = var.REGION
    IMAGE_ADDR = aws_ecr_repository.zip_service_repo.repository_url
    SERVICE    = var.SERVICE
    STAGE      = var.STAGE
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "ARM64"
  }

  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.zip_service.arn
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  requires_compatibilities = ["FARGATE"]
  tags                     = local.common_tags
}

resource aws_ecs_service zip_service {
  name            = "${var.SERVICE}-${var.STAGE}-ecs-service-zip-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.zip_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  tags            = local.common_tags

  network_configuration {
    security_groups  = [aws_security_group.lambda.id] # to access dynamodb and s3
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  depends_on = [
    aws_iam_role.zip_service
  ]
}

resource aws_iam_role zip_service {
  name               = "${var.SERVICE}-${var.STAGE}-zip-service"
  assume_role_policy = data.aws_iam_policy_document.zip_service_policy.json
  tags               = local.common_tags
}

data aws_iam_policy_document zip_service_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource aws_iam_policy zip_service_policy {
  name        = "${var.SERVICE}-${var.STAGE}-zip-service"
  description = "${var.SERVICE}-${var.STAGE}-zip-service"
  path        = "/"
  policy      = data.aws_iam_policy_document.zip_service.json
}

resource "aws_iam_policy_attachment" "zip_service" {
  name       = "${var.SERVICE}-${var.STAGE}-zip-service"
  roles      = [aws_iam_role.zip_service.name]
  policy_arn = aws_iam_policy.zip_service_policy.arn
}

data aws_iam_policy_document zip_service {
  statement {
    sid = "AllowECR"

    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForPlayer",
      "ecr:GetAuthorizationToken",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyReview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:CompleteLayerUpload",
      "ecr:StartImageScan",
      "ecr:InitiateLayerUpload"
    ]

    resources = [aws_ecr_repository.zip_service_repo.arn]
  }

  statement {
    sid = "AllowECS"

    actions = [
      "ecs:CreateCluster",
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:ListServices",
      "ecs:ListContainerInstances",
      "ecs:ListClusters",
      "ecs:ListTaskDefinitions"
    ]

    resources = [aws_ecr_repository.zip_service_repo.arn]
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

    resources = concat(local.dynamodb_tables, [for table in local.dynamodb_tables : "${table}*"])
  }

  statement {
    sid = "KMS"

    actions = [
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = compact(local.kms_keys)
  }

  statement {
    sid = "SQS"

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]

    resources = concat(local.sqs_queues, [for queue in local.sqs_queues : "${queue}*"])
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

    resources = concat(compact(local.s3_buckets), [for bucket in compact(local.s3_buckets) : "${bucket}/*"])
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
    sid = "InvokeLambda"

    actions = [
      "lambda:*"
    ]

    resources = [
      "arn:aws:lambda:${var.REGION}:${data.aws_caller_identity.current.account_id}:function:*"
    ]
  }
}

output ecs_cluster {
  value = aws_ecs_cluster.cluster.name
}
