resource "aws_route53_record" "ingester" {
  zone_id = "${var.dns_zone_id}"
  name    = "ingester"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_instance.ingester.private_dns}"]
}
