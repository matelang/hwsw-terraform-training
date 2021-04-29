resource "tls_private_key" "key" {
  algorithm = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "request" {
  key_algorithm = tls_private_key.key.algorithm
  private_key_pem = tls_private_key.key.private_key_pem
  subject {
    common_name = var.name
  }
}