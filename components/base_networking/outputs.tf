output "vpc_id" {
  description = "The ID of the created VPC."
  value       = "${module.training_vpc.vpc_id}"
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = "${module.training_vpc.public_subnet_ids}"
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = "${module.training_vpc.private_subnet_ids}"
}

output "dns_zone_id" {
  description = "ID of the private DNS zone attached to the VPC."
  value       = "${module.training_vpc.dns_zone_id}"
}

output "vpc_default_security_group_id" {
  description = "ID of the default SG for the VPC"
  value       = "${module.training_vpc.vpc_default_security_group_id}"
}
