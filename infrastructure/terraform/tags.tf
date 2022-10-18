locals {
  common_tags = {
    Service           = var.SERVICE
    Stage             = var.STAGE
  }
}

output tags {
  value = local.common_tags
}
