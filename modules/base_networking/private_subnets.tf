resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  count             = "${length(var.availability_zones)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-subnet-${element(var.availability_zones, count.index)}-${var.deployment_identifier}",
      "Tier", "private"
    )
  )}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-routetable-${var.deployment_identifier}",
      "Tier", "private"
    )
  )}"
}

resource "aws_route" "private_internet" {
  route_table_id         = "${aws_route_table.private.id}"
  nat_gateway_id         = "${aws_nat_gateway.nat_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
