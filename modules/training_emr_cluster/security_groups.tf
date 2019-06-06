resource "aws_security_group" "master" {
  name        = "emr-master-${var.deployment_identifier}"
  description = "AWS Managed security group for EMR master node"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }

  revoke_rules_on_delete = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "emr-master-${var.deployment_identifier}"
    )
  )}"

}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.master.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress for master EMR node"
}

resource "aws_security_group" "core" {
  name        = "emr-core-${var.deployment_identifier}"
  description = "AWS Managed security group for EMR core nodes"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }

  revoke_rules_on_delete = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "emr-core-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_security_group_rule" "core_egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.core.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress for core EMR node"
}

resource "aws_security_group" "service" {
  name        = "emr-service-${var.deployment_identifier}"
  description = "AWS Managed security group for EMR service"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    ignore_changes = ["ingress", "egress"]
  }

  revoke_rules_on_delete = true

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "emr-service-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_security_group" "emr_shared" {

  name        = "emr-shared-${var.deployment_identifier}"
  description = "Allow other services to connect to EMR nodes"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "emr-shared-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_security_group_rule" "bastion_ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "SSH"
}

resource "aws_security_group_rule" "bastion_yarn_resourcemanager" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 8088
  to_port                  = 8088
  protocol                 = "tcp"
  description              = "YARN ResourceManager: http://master-dns-name:8088/"
}

resource "aws_security_group_rule" "bastion_yarn_nodemanager" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 8042
  to_port                  = 8042
  protocol                 = "tcp"
  description              = "YARN NodeManager: http://worker-dns-name:8042/"
}

resource "aws_security_group_rule" "bastion_hdfs_namenode" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 50070
  to_port                  = 50070
  protocol                 = "tcp"
  description              = "Hadoop HDFS NameNode: http://master-dns-name:50070/"
}

resource "aws_security_group_rule" "bastion_hdfs_datanode" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 50075
  to_port                  = 50075
  protocol                 = "tcp"
  description              = "Hadoop HDFS DataNode: http://worker-dns-name:50075/"
}

resource "aws_security_group_rule" "bastion_spark_history" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 18080
  to_port                  = 18080
  protocol                 = "tcp"
  description              = "Spark HistoryServer: http://master-dns-name:18080/"
}

resource "aws_security_group_rule" "bastion_zeppelin" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 8890
  to_port                  = 8890
  protocol                 = "tcp"
  description              = "Zeppelin: http://master-dns-name:8890/"
}

resource "aws_security_group_rule" "bastion_hue" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 8888
  to_port                  = 8888
  protocol                 = "tcp"
  description              = "Hue: http://master-dns-name:8888/"
}

resource "aws_security_group_rule" "bastion_ganglia" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Ganglia: http://master-dns-name/ganglia/"
}

resource "aws_security_group_rule" "bastion_hbase" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.emr_shared.id}"
  source_security_group_id = "${var.bastion_security_group_id}"
  from_port                = 16010
  to_port                  = 16010
  protocol                 = "tcp"
  description              = "HBase UI: http://master-dns-name:16010/"
}
