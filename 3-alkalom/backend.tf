terraform {
  backend "s3" {
    bucket = "hwsw-2021-tf-state"
    region = "eu-central-1"
    key = "terraform.tfstate"
  }
}