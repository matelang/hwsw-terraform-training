resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "HWSW"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count = length(var.azs)

  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone_id = data.aws_availability_zones.available.zone_ids[
  index(data.aws_availability_zones.available.zone_ids, var.azs[count.index])]

  tags = {
    Name = join("-", [
      "hwsw-public",
      count.index])
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "hwsw-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "hwsw-public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.azs)

  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[count.index].id
}
