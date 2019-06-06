resource "aws_eip" "nat" {
  vpc = true
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "nat-eip-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.0.id}"
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "nat-gateway-${var.deployment_identifier}"
    )
  )}"

  depends_on = [
    "aws_internet_gateway.internet_gateway"
  ]
}
