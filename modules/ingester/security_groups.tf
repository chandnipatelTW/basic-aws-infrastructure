resource "aws_security_group" "ingester" {

  name        = "ingester-${var.deployment_identifier}"
  description = "Security group for ingester"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "ingester-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_security_group_rule" "bastion_ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.ingester.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "SSH from Bastion to ingester"
}

resource "aws_security_group_rule" "ingester_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.ingester.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress for ingester"
}

resource "aws_security_group_rule" "kafka_ingester_ingress_broker" {
  type                     = "ingress"
  security_group_id        = "${var.kafka_security_group_id}"
  source_security_group_id = "${aws_security_group.ingester.id}"
  from_port                = 9092
  to_port                  = 9092
  protocol                 = "tcp"
  description              = "Kafka broker ingress for data ingester"
}

resource "aws_security_group_rule" "kafka_ingester_ingress_zookeeper" {
  type                     = "ingress"
  security_group_id        = "${var.kafka_security_group_id}"
  source_security_group_id = "${aws_security_group.ingester.id}"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  description              = "Zookeeper ingress for data ingester"
}
