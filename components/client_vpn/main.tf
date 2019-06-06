terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.26"
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
  server_cert_arn            = "arn:aws:acm:ap-southeast-1:618886044591:certificate/2df22a1e-500d-4933-9bed-1c4ecb5e0c15"
  root_certificate_chain_arn = "arn:aws:acm:ap-southeast-1:618886044591:certificate/a21e1ff4-21b6-4997-9080-9649e7a0bd37"
}