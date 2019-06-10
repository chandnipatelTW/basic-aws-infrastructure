terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

data "terraform_remote_state" "base_networking" {
  backend = "s3"
  config {
    key    = "base_networking.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

module "client_vpn" {
  source                = "../../modules/client_vpn"
  subnet_ids            = "${data.terraform_remote_state.base_networking.public_subnet_ids}"
  security_group_id     = "${data.terraform_remote_state.base_networking.vpc_default_security_group_id}"
  deployment_identifier = "data-eng-${var.cohort}"
  cohort                = "${var.cohort}"
  client_cidr_block     = "10.10.0.0/16"
}