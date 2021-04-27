resource "aws_security_group" "lb" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "API Load Balancer"
  }
}

module "lb" {
  source = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  name = local.derived_name

  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [
    aws_security_group.lb.id]
  internal = false

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port = 5678
      target_type = "instance"
      deregistration_delay = 10

      health_check = {
        interval = 10
        path = "/"
        protocol = "HTTP"
        matcher = "200"
      }
    }
  ]

  https_listeners = [
        {
          port            = 443
          protocol        = "HTTPS"
          certificate_arn = module.acm.acm_certificate_arn
        }
  ]

}