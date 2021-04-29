provider "tls" {
}

locals {
  names = toset(["johny", "kenny", "elon"])
}

module "keys" {
  for_each = local.names

  source = "./modules"
  name = each.value
}

output "public_key" {
  value = module.keys["johny"].public
}
