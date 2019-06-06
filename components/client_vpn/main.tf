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
  server_cert_arn            = "arn:aws:acm:ap-southeast-1:618886044591:certificate/a86137cd-368c-4425-a173-95a6c9e9779a"
  root_certificate_chain_arn = "arn:aws:acm:ap-southeast-1:618886044591:certificate/7a93d262-20ee-43bd-8f55-ef13454e963c"
}