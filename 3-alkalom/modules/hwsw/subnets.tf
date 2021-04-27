module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.aws_vpc_cidr

  networks = [
    {
      name     = "private-1"
      new_bits = 2
    },
    {
      name     = "private-2"
      new_bits = 2
    },
    {
      name     = "private-3"
      new_bits = 2
    },
    {
      name     = "na-1"
      new_bits = 3
    },
    {
      name     = "public-1"
      new_bits = 6
    },
    {
      name     = "public-2"
      new_bits = 6
    },
    {
      name     = "public-3"
      new_bits = 6
    },
    {
      name     = "na-2"
      new_bits = 6
    },
    {
      name     = "na-3"
      new_bits = 4
    },
  ]
}

locals {
  subnet_addr_network_keys = sort(keys(module.subnet_addrs.network_cidr_blocks))
  private_subnet_cidrs     = [for k in local.subnet_addr_network_keys : module.subnet_addrs.network_cidr_blocks[k] if length(regexall("^private-\\d*$", k)) > 0]
  public_subnet_cidrs      = [for k in local.subnet_addr_network_keys : module.subnet_addrs.network_cidr_blocks[k] if length(regexall("^public-\\d*$", k)) > 0]
}
