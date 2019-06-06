output "airflow_address" {
  description = "The DNS address of the airflow instance."
  value       = "${module.training_airflow.airflow_address}"
}
