variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "vpc_id" {
  description = "VPC in which to provision Kafka"
}

variable "subnet_id" {
  description = "Subnet in which to provision Kafka"
}

variable "ec2_key_pair" {
  description = "EC2 key pair to use to SSH into Kafka instance"
}

variable "dns_zone_id" {
  description = "DNS zone in which to create records"
}

variable "instance_type" {
  description = "EC2 instance type for Kafka"
}

variable "bastion_security_group_id" {
  description = "Id of bastion security group to allow SSH ingress"
}

variable "airflow_security_group_id" {
  description = "Id of airflow security group to allow SSH ingress"
}

variable "emr_security_group_id" {
  description = "Id of EMR cluster security group to Kafka & Zookeeper ingress"
}

variable "data_volume_type" {
  description = "Type of the volume where Kafka and Zookeeper data resides"
  default = "gp2"
}

variable "data_volume_size" {
  description = "Size, in GB, of the volume where Kafka and Zookeeper data resides"
}

variable "data_device_name" {
  description = "Name of the device for the volume where Kafka and Zookeeper data resides"
  default = "/dev/sdf"
}

variable "data_dir" {
  description = "Name of the directory where Kafka and Zookeeper data resides"
  default = "/data"
}

variable "aws_region" {
  description = "Region in which to build resources."
}


