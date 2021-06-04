variable "org" {
  type = string
}

variable "prod" {
  type    = string
  default = "prod"
}

variable "test" {
  type    = string
  default = "test"
}

variable "eu_west_1" {
  type    = string
  default = "eu-west-1"
}

variable "us_east_1" {
  type    = string
  default = "us-east-1"
}

variable "aws_account_id" {
  type = string
}

variable "base_domain_route_53_hosted_zone_id" {
  type = string
}
