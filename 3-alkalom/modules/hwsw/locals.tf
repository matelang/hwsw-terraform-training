locals {
  name_prefix = "hwsw"

  derived_name = join("-", [local.name_prefix, var.name])
}
