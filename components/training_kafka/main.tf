terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"}

data "terraform_remote_state" "base_networking" {
  backend = "s3"
  config {
    key    = "base_networking.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config {
    key    = "bastion.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "training_emr_cluster" {
  backend = "s3"
  config {
    key    = "training_emr_cluster.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

module "training_kafka" {
  source = "../../modules/training_kafka"

  bastion_security_group_id = "${data.terraform_remote_state.bastion.bastion_security_group_id}"
  emr_security_group_id     = "${data.terraform_remote_state.training_emr_cluster.security_group_id}"
  deployment_identifier     = "data-eng-${var.cohort}"
  vpc_id                    = "${data.terraform_remote_state.base_networking.vpc_id}"
  subnet_id                 = "${data.terraform_remote_state.base_networking.private_subnet_ids[0]}"
  ec2_key_pair              = "tw-dataeng-${var.cohort}"
  dns_zone_id               = "${data.terraform_remote_state.base_networking.dns_zone_id}"
  instance_type             = "${var.kafka["instance_type"]}"
}
