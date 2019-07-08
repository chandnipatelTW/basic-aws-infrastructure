output "airflow_security_group_id" {
  description = "ID of the airflow security group."
  value       = "${module.training_airflow.airflow_security_group_id}"
}

output "airflow_address" {
  description = "The DNS address of the airflow instance."
  value       = "${module.training_airflow.airflow_address}"
}
