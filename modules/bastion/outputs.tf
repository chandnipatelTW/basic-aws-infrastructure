output "bastion_security_group_id" {
  description = "The ID of bastion security group."
  value       = "${aws_security_group.bastion.id}"
}

output "bastion_ip_address" {
  description = "The public IP address of the bastion."
  value       = "${aws_eip.bastion.public_ip}"
}
