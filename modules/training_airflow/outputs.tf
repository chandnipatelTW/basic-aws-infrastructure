output "airflow_address" {
  description = "The DNS address of the airflow instance."
  value       = "${aws_route53_record.airflow.fqdn}"
}
output "airflow_security_group_id" {
  description = "The ID of airflow security group."
  value       = "${aws_security_group.airflow.id}"
}
