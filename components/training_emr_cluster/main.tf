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

module "training_cluster" {
  source = "../../modules/training_emr_cluster"

  deployment_identifier     = "data-eng-${var.cohort}"
  ec2_key_pair              = "tw-dataeng-${var.cohort}"
  vpc_id                    = "${data.terraform_remote_state.base_networking.vpc_id}"
  subnet_id                 = "${data.terraform_remote_state.base_networking.private_subnet_ids[0]}"
  dns_zone_id               = "${data.terraform_remote_state.base_networking.dns_zone_id}"
  master_type               = "${var.emr_cluster["master_type"]}"
  core_type                 = "${var.emr_cluster["core_type"]}"
  core_count                = "${var.emr_cluster["core_count"]}"
  bastion_security_group_id = "${data.terraform_remote_state.bastion.bastion_security_group_id}"
}
