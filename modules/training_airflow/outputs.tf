output "airflow_address" {
  description = "The DNS address of the airflow instance."
  value       = "${aws_route53_record.airflow.fqdn}"
}
