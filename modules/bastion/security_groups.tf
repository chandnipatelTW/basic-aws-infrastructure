resource "aws_security_group" "bastion" {
  name   = "bastion-${var.deployment_identifier}"
  vpc_id = "${var.vpc_id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "bastion-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks       = "${var.allowed_cidrs}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "SSH in to Bastion"
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress for Bastion"
}
