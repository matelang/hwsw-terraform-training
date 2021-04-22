resource "aws_route53_delegation_set" "delegation_set" {
  reference_name = "hwsw"
}

resource "aws_route53_zone" "hwsw" {
  name = "hwsw.binhatch.dev"
  delegation_set_id = aws_route53_delegation_set.delegation_set.id
}

resource "aws_route53_record" "api" {
  name = "api"
  type = "CNAME"
  zone_id = aws_route53_zone.hwsw.zone_id
  records = [
    aws_lb.lb.dns_name]
  ttl = 300
}
