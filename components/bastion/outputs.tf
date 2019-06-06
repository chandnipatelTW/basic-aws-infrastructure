output "bastion_security_group_id" {
  description = "ID of the bastion security group."
  value       = "${module.bastion.bastion_security_group_id}"
}

output "bastion_ip_address" {
  description = "The public IP address of the bastion."
  value       = "${module.bastion.bastion_ip_address}"
}
