variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "vpc_id" {
  description = "VPC in which to provision Kafka"
}

variable "subnet_id" {
  description = "Subnet in which to provision Kafka"
}

variable "ec2_key_pair" {
  description = "EC2 key pair to use to SSH into Kafka instance"
}

variable "dns_zone_id" {
  description = "DNS zone in which to create records"
}

variable "instance_type" {
  description = "EC2 instance type for Kafka"
}

variable "bastion_security_group_id" {
  description = "Id of bastion security group to allow SSH ingress"
}

variable "emr_security_group_id" {
  description = "Id of EMR cluster security group to Kafka & Zookeeper ingress"
}
