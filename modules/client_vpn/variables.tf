variable "client_cidr_block" {
  description = "The CIDR to use for the clients"
}

variable "server_cert_arn" {
  description = "The ARN for the VPN server cert"
}

variable "root_certificate_chain_arn" {
  description = "Chain of trust anchor"
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