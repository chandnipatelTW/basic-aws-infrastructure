variable "client_cidr_block" {
  description = "The CIDR to use for the clients"
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "subnet_ids" {
  description = "Subnet IDs to attach the VPN to"
  type        = "list"
}

variable "dns_servers" {
  description = "DNS server for the Client"
  type        = "list"
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "security_group_id" {
  description = "Security group for the VPN connection"
}

variable "cohort" {
  description = "Training cohort, eg: london-summer-2018"
}