resource aws_security_group lambda {
  name        = "${var.SERVICE}-${var.STAGE}-lambda"
  description = "Security group for lambda"

  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
}

resource aws_security_group_rule allow_lambda_to_s3_dynamodb {
  description              = "Allow lambda to access S3 & DynamoDB within the same region"

  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = aws_security_group.lambda.id
  prefix_list_ids          = [for m in module.endpoints.endpoints : m.prefix_list_id]

}

resource aws_security_group_rule allow_lambda_to_https_internet {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  ipv6_cidr_blocks  = ["::/0"] #tfsec:ignore:AWS007

  description       = "Allow lambda to access HTTPS internet"
  security_group_id = aws_security_group.lambda.id
}


output lambda_sg {
  value      = join("", aws_security_group.lambda.*.id)

  depends_on = [
    aws_security_group.lambda
  ]
}
