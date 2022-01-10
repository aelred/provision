resource aws_route53_record aelred {
  type = "A"
  name = "valheim.${var.domain}"
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl = 43200
  records = ["45.159.7.132"]
}

data aws_route53_zone zone {
  name = var.domain
}
