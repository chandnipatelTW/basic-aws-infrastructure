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

module "bastion" {
  source = "../../modules/bastion"

  deployment_identifier = "data-eng-${var.cohort}"
  instance_type         = "t2.micro"
  vpc_id                = "${data.terraform_remote_state.base_networking.vpc_id}"
  subnet_id             = "${data.terraform_remote_state.base_networking.public_subnet_ids[0]}"
  ec2_key_pair          = "tw-dataeng-${var.cohort}"
  allowed_cidrs         = ["0.0.0.0/0"]
}

