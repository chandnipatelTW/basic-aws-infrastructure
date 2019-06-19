output "client_vpn_id" {
  description = "The ID of client vpn (can be used to generaten openvpn config file)."
  value       = "${aws_ec2_client_vpn_endpoint.client_vpn.id}"
}
