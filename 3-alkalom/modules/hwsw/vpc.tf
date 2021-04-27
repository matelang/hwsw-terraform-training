data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = local.derived_name

  cidr = var.aws_vpc_cidr
  azs = data.aws_availability_zones.available.zone_ids
  private_subnets = local.private_subnet_cidrs
  public_subnets = local.public_subnet_cidrs
  enable_dns_hostnames = true
  enable_dns_support = true

  enable_nat_gateway = true
  single_nat_gateway = true
}
