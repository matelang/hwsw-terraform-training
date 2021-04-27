module "web" {
  source = "cloudposse/cloudfront-s3-cdn/aws"
  version = "0.55.0"

  name           = "${local.derived_name}-webapp"
  parent_zone_id = aws_route53_zone.hwsw.id

  acm_certificate_arn      = module.acm-app.acm_certificate_arn

  aliases                  = ["app.${local.derived_acm_domain_name}"]
  dns_alias_enabled        = true
  origin_force_destroy     = true
  cors_allowed_headers = [
    "*"]
  cors_allowed_methods = [
    "GET",
    "HEAD",
    "PUT"]
  cors_allowed_origins = [
    "*.${aws_route53_zone.hwsw.name}"]
  cors_expose_headers = [
    "ETag"]
  website_enabled     = true
  logging_enabled     = false
  wait_for_deployment = false
  routing_rules       = <<EOF
[{
    "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
    },
    "Redirect": {
        "HostName": "app.${local.derived_acm_domain_name}",
        "ReplaceKeyPrefixWith": "#!/"
    }
},
{
    "Condition": {
        "HttpErrorCodeReturnedEquals": "403"
    },
    "Redirect": {
        "HostName": "app.${local.derived_acm_domain_name}",
        "ReplaceKeyPrefixWith": "#!/"
    }
}]
EOF
}

resource "aws_s3_bucket_object" "index" {
  bucket = module.web.s3_bucket
  key = "index.html"
  source = "index.html"
  content_type = "text/html"
}
