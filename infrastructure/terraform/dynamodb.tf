module dynamodb_main {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "${var.SERVICE}-${var.STAGE}-main"
  hash_key       = "PK"
  range_key      = "SK"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  server_side_encryption_enabled     = true
  # server_side_encryption_kms_key_arn = "alias/aws/dynamodb"

  autoscaling_read = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }
  
  autoscaling_write = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  
  # ttl_attribute_name = "ttl"

  attributes = [
    {
      name = "PK"
      type = "S"
    },
    {
      name = "SK"
      type = "S"
    }
  ]

  global_secondary_indexes = []

  tags = local.common_tags
}

output dynamodb_main {
  value = module.dynamodb_main.dynamodb_table_id
}

