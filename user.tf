resource "aws_iam_user" "cicd-os" {
  name = var.cicd-name
  tags = { Name = var.cicd-name }
}

variable "cicd-name" {
  default = "cicd-os"
  type    = string
}
