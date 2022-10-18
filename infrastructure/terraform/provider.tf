terraform {
  backend "s3" {}
}

provider aws {
  region = var.REGION
}

provider "aws" {
  alias   = "north_virginia"
  region  = "us-east-1"
}
