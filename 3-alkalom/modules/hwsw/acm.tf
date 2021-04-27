locals {
  derived_acm_domain_name = trimsuffix(aws_route53_zone.hwsw.name, ".")
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.0.0"

  domain_name = "api.${local.derived_acm_domain_name}"

  zone_id             = aws_route53_zone.hwsw.id
  wait_for_validation = true
}

module "acm-app" {
  providers = {
    aws = aws.cf
  }

  source  = "terraform-aws-modules/acm/aws"
  version = "3.0.0"

  domain_name = "app.${local.derived_acm_domain_name}"

  zone_id             = aws_route53_zone.hwsw.id
  wait_for_validation = true
}
