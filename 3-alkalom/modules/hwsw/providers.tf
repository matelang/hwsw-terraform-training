provider "aws" {
  region = var.region
}

provider "aws" {
  alias = "cf"
  region = "us-east-1"
}