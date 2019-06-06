resource "aws_db_instance" "airflow_postgres" {
  identifier = "training-airflow-${var.deployment_identifier}"

  snapshot_identifier    = "${var.initial_rds_snapshot}"
  instance_class         = "${var.rds_instance_class}"
  vpc_security_group_ids = ["${aws_security_group.airflow_rds.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.airflow_postgres.name}"
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "training-airflow-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_db_subnet_group" "airflow_postgres" {
  name       = "training-airflow-${var.deployment_identifier}"
  subnet_ids = ["${var.subnet_ids}"]

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "training-airflow-${var.deployment_identifier}"
    )
  )}"
}
