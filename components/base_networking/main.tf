terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.26"
}

module "training_vpc" {
  source = "../../modules/base_networking"

  deployment_identifier = "data-eng-${var.cohort}"
  vpc_cidr              = "10.0.0.0/16"
  private_dns_zone_name = "${var.cohort}.training"
  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
}
