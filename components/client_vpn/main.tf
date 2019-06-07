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
  source                     = "../../modules/client_vpn"
  subnet_ids                 = "${data.terraform_remote_state.base_networking.public_subnet_ids}"
  security_group_id          = "${data.terraform_remote_state.base_networking.vpc_default_security_group_id}"
  deployment_identifier      = "data-eng-${var.cohort}"
  client_cidr_block          = "10.10.0.0/16"
  server_cert_arn            = "arn:aws:acm:ap-southeast-1:618886044591:certificate/b78d65b0-1fe0-49c0-9e29-2c7c74a750f5"
  root_certificate_chain_arn = "arn:aws:acm:ap-southeast-1:618886044591:certificate/9627ceb2-8c63-439e-b26e-3e42d50db014"
}