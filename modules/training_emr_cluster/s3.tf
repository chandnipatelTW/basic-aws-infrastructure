resource "aws_s3_bucket" "emr_logs" {
  bucket = "${var.deployment_identifier}-emr-logs"
  acl    = "private"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${var.deployment_identifier}-emr-logs"
    )
  )}"
}
