resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "internet-gateway-${var.deployment_identifier}",
      "Tier", "public"
    )
  )}"
}
