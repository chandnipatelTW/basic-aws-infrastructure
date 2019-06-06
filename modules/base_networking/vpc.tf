resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "vpc-${var.deployment_identifier}"
    )
  )}"
}
