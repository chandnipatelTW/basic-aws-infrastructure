terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

locals {
  deployment_identifier = "data-eng-${var.cohort}"
}

resource "aws_s3_bucket" "training_data" {
  bucket = "${local.deployment_identifier}-training-data"
  acl    = "private"

  tags = {
    Name                 = "${local.deployment_identifier}-training-data"
    Automation           = "terraform"
    DeploymentIdentifier = "${local.deployment_identifier}"
  }
}
