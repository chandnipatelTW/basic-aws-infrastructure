variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "vpc_id" {
  description = "VPC in which to launch cluster"
}

variable "subnet_id" {
  description = "Subnet in which to launch cluster"
}

variable "dns_zone_id" {
  description = "DNS zone in which to create records"
}

variable "ec2_key_pair" {
  description = "EC2 key pair to use to SSH into bastion"
}

variable "master_type" {
  description = "Instance type of master node"
}

variable "core_type" {
  description = "Instance type of core node"
}

variable "core_count" {
  description = "Number of core nodes"
}

variable "bastion_security_group_id" {
  description = "Id of bastion security group to allow SSH ingress"
}
