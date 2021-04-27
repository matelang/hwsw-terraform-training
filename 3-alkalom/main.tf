variable "aws_vpc_cidr" {
  type = string
}

variable "name" {
  type = string
}

module "hwsw" {
  source = "./modules/hwsw"

  aws_vpc_cidr = var.aws_vpc_cidr
  name = var.name
}