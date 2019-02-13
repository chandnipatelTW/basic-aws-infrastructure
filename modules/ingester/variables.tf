variable "dns_zone_id" {
  description = "DNS zone in which to create a cname record."
}

variable "instance_type" {
  description = "EC2 instance type for ingester."
}

variable "subnet_id" {
  description = "Public subnet in which to provision ingester"
}

variable "ec2_key_pair" {
  description = "Ec2 key name to use to SSH into ingester."
}

variable "vpc_id" {
  description = "VPC in which to provision ingester."
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "bastion_security_group_id" {
  description = "The security group id for bastion."
}

variable "kafka_security_group_id" {
  description = "The security group id of Kafka to ingest to."
}
