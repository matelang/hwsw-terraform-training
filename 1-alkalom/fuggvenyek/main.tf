locals {
  a = 10
  b = 20

  minab = min(local.a, local.b)
  hostnev = format("host-%d-%s", local.a, "host")

  nevek = [
    "johny",
    "kenny",
    "elon"]
  hostnevek = formatlist("host-%s", local.nevek)

  splitted = split("-", "host-123-abcd")

  aMap = {
    "x" = {
      "name" = "johny",
    },
    "y" = {
      "name" = "kenny",
    },
    "z" = {
      "name" = "elon"
    }
  }
}

output "min" {
  value = local.minab
}

output "hostnev" {
  value = local.hostnev
}

output "hostnevek" {
  value = local.hostnevek
}

output "splitted" {
  value = local.splitted
}

output "mapkeys" {
  value = keys(local.aMap)
}

output "mapvalues" {
  value = values(local.aMap)
}

output "lup" {
  value = lookup(lookup(local.aMap, "x", "default"), "name", "default")
}

output "egy_hash" {
  value = sha256("hello hwsw")
}
