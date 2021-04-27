variable "aws_vpc_cidr" {
  type = string
}

variable "name" {
  type = string
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "region" {
  type = string
  default = "eu-central-1"
}