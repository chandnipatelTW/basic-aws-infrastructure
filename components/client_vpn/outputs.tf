output "client_vpn_id" {
  description = "Client VPN endpoint id, can be used to generate openvpn config file"
  value       = "${module.client_vpn.client_vpn_id}"
}