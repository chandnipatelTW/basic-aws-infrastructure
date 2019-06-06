
resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "terraform-clientvpn-example"
  server_certificate_arn = "${server_cert_arn}"
  client_cidr_block      = "${client_cidr_block}"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = "${root_certificate_chain_arn}"
  }

  connection_log_options {
    enabled = false
  }
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "client-vpn-${var.deployment_identifier}",
      "Tier", "public"
    )
  )}"
}

resource "aws_ec2_client_vpn_network_association" "client_vpn" {
  client_vpn_endpoint_id = "${aws_ec2_client_vpn_endpoint.client_vpn.id}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  count                  = "${length(var.subnet_ids)}"
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "client-vpn-subnet-${element(var.subnet_ids, count.index)}-${var.deployment_identifier}",
      "Tier", "public"
    )
  )}"
}