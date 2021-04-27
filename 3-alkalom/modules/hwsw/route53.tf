resource "aws_route53_zone" "hwsw" {
  name = "hwsw.binhatch.dev"
  delegation_set_id = "N0552769V8EUEN1MEBF3"
}

resource "aws_route53_record" "api" {
  name = "api.${aws_route53_zone.hwsw.name}"
  type = "CNAME"
  zone_id = aws_route53_zone.hwsw.zone_id
  records = [module.lb.lb_dns_name]
  ttl = 300
}