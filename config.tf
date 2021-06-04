provider "aws" {
  alias  = "eu_west_1"
  region = var.eu_west_1
}

provider "aws" {
  alias  = "us_east_1"
  region = var.us_east_1
}

terraform {
  required_version = "0.15.4"
}

