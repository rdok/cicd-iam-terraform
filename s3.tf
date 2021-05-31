resource "aws_s3_bucket" "test-cicd-us-east-1" {
  bucket   = "${var.org}-test-cicd-${var.us_east_1}"
  acl      = "private"
  provider = aws.us_east_1
}

resource "aws_s3_bucket" "prod-cicd-us-east-1" {
  bucket   = "${var.org}-prod-cicd-${var.us_east_1}"
  acl      = "private"
  provider = aws.us_east_1
}

resource "aws_s3_bucket" "test-cicd-eu-west-1" {
  bucket = "${var.org}-test-cicd-${var.eu_west_1}"
  acl    = "private"
  provider = aws.eu_west_1
}

resource "aws_s3_bucket" "prod-cicd-eu-west-1" {
  bucket = "${var.org}-prod-cicd-${var.eu_west_1}"
  acl    = "private"
  provider = aws.eu_west_1
}
