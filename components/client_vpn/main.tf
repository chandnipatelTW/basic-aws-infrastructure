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

data "aws_acm_certificate" "root" {
  domain      = "root.${var.cohort}.training"
  types       = ["IMPORTED"]
  most_recent = true
}

data "aws_acm_certificate" "server" {
  domain      = "openvpn.${var.cohort}.training"
  types       = ["IMPORTED"]
  most_recent = true
}

module "client_vpn" {
  source                     = "../../modules/client_vpn"
  subnet_ids                 = "${data.terraform_remote_state.base_networking.public_subnet_ids}"
  security_group_id          = "${data.terraform_remote_state.base_networking.vpc_default_security_group_id}"
  deployment_identifier      = "data-eng-${var.cohort}"
  client_cidr_block          = "10.10.0.0/16"
  server_cert_arn            = "${data.aws_acm_certificate.server.arn}"
  root_certificate_chain_arn = "${data.aws_acm_certificate.root.arn}"
}