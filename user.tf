resource "aws_iam_user" "cicd-os" {
  name = var.cicd-name
  tags = { Name = var.cicd-name }
}

//data "aws_iam_policy_document" "instance-assume-role-policy" {
//  statement {
//    actions = ["sts:AssumeRole"]
//    principals {
//      type        = "Service"
//      identifiers = ["ec2.amazonaws.com"]
//    }
//  }
//}

variable "cicd-name" {
  default = "cicd-os"
  type    = string
}
