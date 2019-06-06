terraform {
  backend "s3" {}
}

provider "aws" {
  region="${var.aws_region}"
  version = "~> 1.26"
}

data "terraform_remote_state" "base_networking" {
  backend = "s3"
  config {
    key="base_networking.tfstate"
    bucket="tw-dataeng-${var.cohort}-tfstate"
    region="${var.aws_region}"
  }
}


module "client_vpn" {
  source="../../modules/client_vpn"
  subnet_ids = "${data.terraform_remote_state.base_networking.private_subnet_ids}"
  deployment_identifier = "data-eng-${var.cohort}"
  client_cidr_block = ""
  server_cert_arn = ""
  root_certificate_chain_arn = ""
}