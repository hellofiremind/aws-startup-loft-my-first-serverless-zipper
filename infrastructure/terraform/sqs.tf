module "zip_queue" {
  source  = "terraform-aws-modules/sqs/aws"

  name_prefix = "${var.SERVICE}-${var.STAGE}-zip"
  tags        = local.common_tags

  fifo_queue        = true
  kms_master_key_id = aws_kms_key.zip_queue_key.key_id

  visibility_timeout_seconds  = 310
  content_based_deduplication = true
}

resource aws_kms_key zip_queue_key {
  description               = "${var.SERVICE}-${var.STAGE}-zip-queue"
  deletion_window_in_days   = 10
  enable_key_rotation       = true
}

resource aws_kms_alias zip_queue_key {
  name                      = "alias/${var.SERVICE}-${var.STAGE}-zip-queue"
  target_key_id             = aws_kms_key.zip_queue_key.key_id
}

output sqs_zip_name {
  value = module.zip_queue.sqs_queue_name
}

output sqs_zip_arn {
  value = module.zip_queue.sqs_queue_arn
}

output sqs_zip_url {
  value = module.zip_queue.sqs_queue_id
}
