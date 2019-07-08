resource "aws_route53_record" "kafka" {
  zone_id = "${var.dns_zone_id}"
  name    = "kafka"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.kafka.private_dns}"]
}
