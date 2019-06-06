resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  count             = "${length(var.availability_zones)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "public-subnet-${element(var.availability_zones, count.index)}-${var.deployment_identifier}",
      "Tier", "public"
    )
  )}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "public-routetable-${var.deployment_identifier}",
      "Tier", "public"
    )
  )}"
}

resource "aws_route" "public_internet" {
  route_table_id         = "${aws_route_table.public.id}"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
