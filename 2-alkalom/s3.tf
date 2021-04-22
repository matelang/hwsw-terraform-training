locals {
  bucket_name = "hwsw-tf-2021"
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  policy = data.aws_iam_policy_document.bucket_policy.json

  website {
    index_document = "index.html"
  }

}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.bucket.bucket
  key = "index.html"
  source = "index.html"
  content_type = "text/html"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowReadFromAll"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]

    principals {
      type = "*"
      identifiers = [
        "*"]
    }
  }
}
