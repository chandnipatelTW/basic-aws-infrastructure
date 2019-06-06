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
  deployment_identifier      = "data-eng-${var.cohort}"
  client_cidr_block          = "10.10.0.0/16"
  server_cert_arn            = "arn:aws:acm:ap-southeast-1:618886044591:certificate/a9defefc-876f-4f31-9935-4968424f1015"
  root_certificate_chain_arn = "arn:aws:acm:ap-southeast-1:618886044591:certificate/23ed1a5c-53cf-4c54-aafa-aea6dd1e9301"
}