locals {
  cidr_block = "172.20.0.0/18"
  private_subnets = slice(local.subnets,1,4)
  public_subnets = slice(local.subnets,4,7)
  subnets = cidrsubnets(local.cidr_block, 6, 3, 3, 3, 3, 3, 3)
}

data aws_availability_zones available {

}

module vpc {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.SERVICE}-${var.STAGE}"
  cidr = local.cidr_block

  azs             = slice(data.aws_availability_zones.available.names,0,3)
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  public_subnet_ipv6_prefixes   = [1, 2, 3]
  private_subnet_ipv6_prefixes  = [4, 5, 6]
  public_subnet_assign_ipv6_address_on_creation = true
  private_subnet_assign_ipv6_address_on_creation = true
  assign_ipv6_address_on_creation = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = false
  enable_ipv6 = true

  tags = local.common_tags
}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      tags            = local.common_tags
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags            = local.common_tags
    }
  }

  tags = local.common_tags
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [module.vpc.vpc_id]
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

output private_subnets {
  value = module.vpc.private_subnets
}

output public_subnets {
  value = module.vpc.public_subnets
}
