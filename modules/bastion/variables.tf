variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "instance_type" {
  description = "EC2 instance type for bastion"
}

variable "vpc_id" {
  description = "VPC in which to provision bastion"
}

variable "subnet_id" {
  description = "Subnet in which to provision bastion"
}

variable "ec2_key_pair" {
  description = "EC2 key pair to use to SSH into bastion"
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into bastion"
  type        = "list"
}
