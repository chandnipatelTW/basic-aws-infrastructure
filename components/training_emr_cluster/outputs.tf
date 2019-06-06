output "emr_master_address" {
  description = "The DNS address of the master EMR node."
  value       = "${module.training_cluster.emr_master_address}"
}

output "emr_cluster_name" {
  description = "EMR cluster name"
  value       = "${module.training_cluster.emr_cluster_name}"
}

output "security_group_id" {
  description = "Security group shared by all nodes in EMR cluster"
  value       = "${module.training_cluster.shared_security_group_id}"
}

output "emr_cluster_id" {
  description = "EMR cluster id"
  value       = "${module.training_cluster.emr_cluster_id}"
}
