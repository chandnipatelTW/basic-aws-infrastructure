resource "aws_security_group" "kafka" {

  name        = "kafka-${var.deployment_identifier}"
  description = "Security group for Kafka"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "kafka-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_security_group_rule" "bastion_ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kafka.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "SSH from Bastion to Kafka"
}

resource "aws_security_group_rule" "kafka_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.kafka.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress for Kafka"
}

resource "aws_security_group_rule" "kafka_emr_ingress_broker" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kafka.id}"
  source_security_group_id = "${var.emr_security_group_id}"
  from_port                = 9092
  to_port                  = 9092
  protocol                 = "tcp"
  description              = "Kafka broker ingress for EMR cluster"
}

resource "aws_security_group_rule" "kafka_emr_ingress_zookeeper" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kafka.id}"
  source_security_group_id = "${var.emr_security_group_id}"
  from_port                = 2181
  to_port                  = 2181
  protocol                 = "tcp"
  description              = "Zookeeper ingress for EMR cluster"
}
