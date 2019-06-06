variable "vpc_cidr" {
  description = "The CIDR to use for the VPC."
}

variable "availability_zones" {
  description = "The availability zones for which to add subnets."
  type        = "list"
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "private_dns_zone_name" {
  description = "Name of VPC private dns zone"
}
