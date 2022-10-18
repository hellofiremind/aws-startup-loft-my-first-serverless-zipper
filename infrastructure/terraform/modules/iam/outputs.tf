output lambda_role_arn {
  value = join("", aws_iam_role.lambda_role.*.arn)
}
