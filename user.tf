resource "aws_iam_user" "cicd-os" {
  name = var.cicd-name
  tags = {
    Name        = var.cicd-name,
    Description = "Common CI/CD user for many repositories."
  }
}

data "aws_iam_policy_document" "cicd-os-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.cicd-os.arn]
    }
  }
}

variable "cicd-name" {
  default = "cicd-os"
  type    = string
}
