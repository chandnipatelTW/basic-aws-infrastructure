resource "aws_route53_resolver_endpoint" "resolver_indbound_endpoint" {
  name            = "resolver_indbound_endpoint-${var.deployment_identifier}"
  direction       = "INBOUND"

  security_group_ids = [
    "${aws_vpc.vpc.default_security_group_id}"
  ]

  ip_address {
    subnet_id = "${element(aws_subnet.public.*.id,0)}"
  }

  ip_address {
    subnet_id = "${element(aws_subnet.public.*.id,1)}"
  }

  ip_address {
    subnet_id = "${element(aws_subnet.public.*.id,2)}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "resolver_indbound_endpoint-${var.deployment_identifier}"
    )
  )}"
}
