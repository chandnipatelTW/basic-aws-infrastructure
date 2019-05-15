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

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config {
    key="bastion.tfstate"
    bucket="tw-dataeng-${var.cohort}-tfstate"
    region="${var.aws_region}"
  }
}

data "terraform_remote_state" "training_kafka" {
  backend = "s3"
  config {
    key="training_kafka.tfstate"
    bucket="tw-dataeng-${var.cohort}-tfstate"
    region="${var.aws_region}"
  }
}

output "ingester_instance_id" {
  description = "The instance id."
  value = "${module.ingester.ingester_instance_id}"
}

module "ingester" {
  source="../../modules/ingester"

  dns_zone_id = "${data.terraform_remote_state.base_networking.dns_zone_id}"
  instance_type = "${var.ingester["instance_type"]}"
  subnet_id = "${data.terraform_remote_state.base_networking.public_subnet_ids[0]}"
  ec2_key_pair = "tw-dataeng-${var.cohort}"
  vpc_id = "${data.terraform_remote_state.base_networking.vpc_id}"
  deployment_identifier = "data-eng-${var.cohort}"
  bastion_security_group_id ="${data.terraform_remote_state.bastion.bastion_security_group_id}"
  kafka_security_group_id = "${data.terraform_remote_state.training_kafka.kafka_security_group_id}"
}
