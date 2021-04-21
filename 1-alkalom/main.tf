provider "tls" {

}

locals {
  algorithm = "ECDSA"
  curve     = "P256"
}

variable "ca_name" {
  type = string
}

variable "ca_validity_hours" {
  type    = number
  default = 2400
}

variable "requester_list" {
  type    = list(string)
  default = []
}

variable "requester_map" {
  type = map(object({
    name     = string,
    validity = number,
  }))
}

// CA

resource "tls_private_key" "ca_key" {
  algorithm   = local.algorithm
  ecdsa_curve = local.curve
}

resource "tls_self_signed_cert" "ca" {
  allowed_uses = [
  "cert_signing"]
  key_algorithm         = tls_private_key.ca_key.algorithm
  private_key_pem       = tls_private_key.ca_key.private_key_pem
  validity_period_hours = var.ca_validity_hours
  subject {
    common_name = var.ca_name
  }
}

// Keres
resource "tls_private_key" "requester" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "requester" {
  key_algorithm   = tls_private_key.requester.algorithm
  private_key_pem = tls_private_key.requester.private_key_pem
  subject {
    common_name = "hwsw-requester"
  }
}

// Alairas
resource "tls_locally_signed_cert" "signed" {
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_key_algorithm      = tls_private_key.ca_key.algorithm
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  cert_request_pem      = tls_cert_request.requester.cert_request_pem
  validity_period_hours = 240
}


output "cert" {
  value = tls_locally_signed_cert.signed.cert_pem
}

output "ca_priv_key" {
  value     = tls_private_key.ca_key.private_key_pem
  sensitive = true
}




///
///
//
//



// Keres + Alairas
resource "tls_private_key" "requester_l" {
  count = length(var.requester_list)

  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "requester_l" {
  count = length(var.requester_list)

  key_algorithm   = tls_private_key.requester_l[count.index].algorithm
  private_key_pem = tls_private_key.requester_l[count.index].private_key_pem

  subject {
    common_name = join("-", ["hwsw-requester", count.index])
  }
}

resource "tls_locally_signed_cert" "signed_l" {
  count = length(var.requester_list)

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_key_algorithm      = tls_private_key.ca_key.algorithm
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  cert_request_pem      = tls_cert_request.requester_l[count.index].cert_request_pem
  validity_period_hours = 240
}

///
///
///
///

resource "tls_private_key" "requester_m" {
  for_each = var.requester_map

  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "requester_m" {
  for_each = var.requester_map

  key_algorithm   = tls_private_key.requester_m[each.key].algorithm
  private_key_pem = tls_private_key.requester_m[each.key].private_key_pem

  subject {
    common_name = join("-", ["hwsw-requester", each.value.name])
  }
}

resource "tls_locally_signed_cert" "signed_m" {
  for_each = var.requester_map

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_key_algorithm      = tls_private_key.ca_key.algorithm
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  cert_request_pem      = tls_cert_request.requester_m[each.key].cert_request_pem
  validity_period_hours = each.value.validity
}

//// CSV

locals {
  csv_file = "be.csv"
  csv      = csvdecode(file(local.csv_file))
}


resource "tls_private_key" "requester_c" {
  for_each = { for k, v in local.csv : v.name => v }

  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}


resource "tls_cert_request" "requester_c" {
  for_each = { for k, v in local.csv : v.name => v }

  key_algorithm   = tls_private_key.requester_c[each.key].algorithm
  private_key_pem = tls_private_key.requester_c[each.key].private_key_pem

  subject {
    common_name = join("-", ["hwsw-requester", each.value["name"]])
  }
}

resource "tls_locally_signed_cert" "signed_c" {
  for_each = { for k, v in local.csv : v.name => v }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_key_algorithm      = tls_private_key.ca_key.algorithm
  ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
  cert_request_pem      = tls_cert_request.requester_c[each.key].cert_request_pem
  validity_period_hours = each.value["validity"]
}
