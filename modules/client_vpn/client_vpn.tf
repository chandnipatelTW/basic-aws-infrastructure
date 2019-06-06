
resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "terraform-clientvpn-example"
  server_certificate_arn = "${var.server_cert_arn}"
  client_cidr_block      = "${var.client_cidr_block}"
  dns_servers            = ["${var.dns_servers}"]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "${var.root_certificate_chain_arn}"
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_ec2_client_vpn_network_association" "client_vpn" {
  client_vpn_endpoint_id = "${aws_ec2_client_vpn_endpoint.client_vpn.id}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  count                  = "${length(var.subnet_ids)}"
}