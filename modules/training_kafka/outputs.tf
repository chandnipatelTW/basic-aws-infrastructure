output "kafka_address" {
  description = "The DNS address of the kafka instance."
  value       = "${aws_route53_record.kafka.fqdn}"
}

output "kafka_security_group_id" {
  description = "Security group of Kafka instance."
  value       = "${aws_security_group.kafka.id}"
}

output "kafka_instance_id" {
  description = "The instance id."
  value       = "${aws_instance.kafka.id}"
}
