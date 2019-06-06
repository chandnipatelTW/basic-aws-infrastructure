variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "instance_type" {
  description = "EC2 instance type for airflow"
}

variable "vpc_id" {
  description = "VPC in which to provision airflow"
}

variable "subnet_ids" {
  description = "Subnet in which to provision airflow and postgres"
  type        = "list"
}

variable "dns_zone_id" {
  description = "DNS zone in which to create records"
}

variable "ec2_key_pair" {
  description = "EC2 key pair to use to SSH into airflow instance"
}

variable "bastion_security_group_id" {
  description = "Id of bastion security group to allow SSH ingress"
}

variable "initial_rds_snapshot" {
  description = "Id of seed RDS snapshot for provisioning Airflow Postgres"
}

variable "rds_snapshot_password_parameter" {
  description = "EC2 parameter store parameter containing password configured in RDS snapshot"
}

variable "rds_instance_class" {
  description = "RDS instance class to use for Airflow Postgres"
}

variable "emr_cluster_name" {
  description = "EMR cluster to automate with airflow"
}
