variable "client_cidr_block" {
  description = "The CIDR to use for the clients"
}

variable "server_cert_arn" {
  description = "The ARN for the VPN server cert"
}

variable "root_certificate_chain_arn" {
  description = "Chain of trust anchor"
}

variable "availability_zones" {
  description = "The availability zones for which to add subnets."
  type = "list"
}

variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "subnet_ids" {
  description = "Subnet IDs to attach the VPN to"
}