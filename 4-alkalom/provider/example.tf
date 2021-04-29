terraform {
  required_providers {
    bitly = {
      source = "github.com/matelang/bitly"
    }
  }
}

provider "bitly" {
  token = ""
}

resource "bitly_bitlink" "newlink" {
  long_url = "https://www.youtube.com/watch?v=9wbZEPrFd10"
  title = "HWSW Csinald Magad Provider"
}

data "bitly_bitlink" "existing" {
  id = "bit.ly/3gL0h9b"
}

output "existing" {
  value = data.bitly_bitlink.existing
}
