output "private" {
  value = tls_private_key.key.private_key_pem
}

output "public" {
  value = tls_private_key.key.public_key_pem
}