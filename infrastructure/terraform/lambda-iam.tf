locals {
  dynamodb_tables = [
    module.dynamodb_main.dynamodb_table_arn
  ]

  kms_keys = [
    aws_kms_key.zip_queue_key.arn,
    aws_kms_key.export_bucket_key.arn,
    aws_kms_key.input_bucket_key.arn
  ]

  s3_buckets = [
    aws_s3_bucket.export_bucket.arn,
    aws_s3_bucket.input_bucket.arn
  ]

  sqs_queues = [
    module.zip_queue.sqs_queue_arn
  ]
}

module iam {
  source          = "./modules/iam"
  STAGE           = var.STAGE
  SERVICE         = var.SERVICE
  REGION          = var.REGION

  DYNAMODB_TABLES = local.dynamodb_tables

  KMS_KEYS = local.kms_keys

  S3_BUCKETS = local.s3_buckets
  SQS_QUEUES = local.sqs_queues
  TAGS       = local.common_tags
}

output lambda_role_arn {
  value = module.iam.lambda_role_arn
}
