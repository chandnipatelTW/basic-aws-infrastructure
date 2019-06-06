output "emr_master_address" {
  description = "The DNS address of the master EMR node."
  value       = "${aws_route53_record.emr_master.fqdn}"
}

output "emr_cluster_name" {
  description = "EMR cluster name"
  value       = "${aws_emr_cluster.training_cluster.name}"
}

output "emr_cluster_id" {
  description = "EMR cluster id"
  value       = "${aws_emr_cluster.training_cluster.id}"
}


output "shared_security_group_id" {
  description = "Id of security group shared by all nodes in EMR cluster"
  value       = "${aws_security_group.emr_shared.id}"
}
