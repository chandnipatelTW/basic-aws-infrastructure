resource "aws_route53_record" "airflow" {
  zone_id = "${var.dns_zone_id}"
  name    = "airflow"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.airflow.private_dns}"]
}

# TODO: CNAME onto RDS
